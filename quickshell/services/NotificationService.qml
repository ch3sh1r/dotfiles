import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// Owns the notification server, live popup objects and persisted history/DND.
// Surfaces consume this shared model and send actions back to this service.
Scope {
    id: root

    readonly property int historyLimit: 10
    property bool dnd: false
    property var popups: []
    property var history: []

    // Restore snapshots only; live notification objects belong to the server.
    function loadState() {
        try {
            let state = JSON.parse(stateFile.text() || "{}");
            root.dnd = state.dnd === true;
            root.history = Array.isArray(state.history)
                ? state.history.slice(0, root.historyLimit)
                : [];
        } catch (e) {
            root.dnd = false;
            root.history = [];
        }
    }

    // Notifications update several properties in a row; coalesce the writes.
    function saveState() {
        saveTimer.restart();
    }

    function writeState() {
        stateFile.setText(JSON.stringify({
            dnd: root.dnd,
            history: root.history
        }, null, 2) + "\n");
    }

    // History must survive expiry/restarts without retaining server objects.
    function snapshot(notification) {
        return {
            id: notification.id,
            appName: notification.appName,
            appIcon: notification.appIcon,
            summary: notification.summary,
            body: notification.body,
            // image:// URLs point at in-memory pixmaps that are gone after a restart.
            image: notification.image.startsWith("image://") ? "" : notification.image,
            urgency: notification.urgency,
            timestamp: new Date().toISOString()
        };
    }

    function record(notification) {
        if (notification.transient) {
            let persistent = root.history.filter(entry => entry.id !== notification.id);
            if (persistent.length !== root.history.length) {
                root.history = persistent;
                root.saveState();
            }
            return;
        }

        let next = [root.snapshot(notification)];
        for (const entry of root.history) {
            if (entry.id !== notification.id && next.length < root.historyLimit)
                next.push(entry);
        }
        root.history = next;
        root.saveState();
    }

    // Track replacement updates as well as the initial delivery.
    function receive(notification) {
        notification.tracked = true;

        let refresh = () => root.refresh(notification);
        notification.appNameChanged.connect(refresh);
        notification.appIconChanged.connect(refresh);
        notification.summaryChanged.connect(refresh);
        notification.bodyChanged.connect(refresh);
        notification.urgencyChanged.connect(refresh);
        notification.actionsChanged.connect(refresh);
        notification.residentChanged.connect(refresh);
        notification.transientChanged.connect(refresh);
        notification.imageChanged.connect(refresh);
        notification.expireTimeoutChanged.connect(refresh);
        notification.closed.connect(reason => {
            root.removePopup(notification.id);
            if (reason !== NotificationCloseReason.Expired)
                root.removeHistory(notification.id);
        });

        root.refresh(notification);
    }

    function refresh(notification) {
        if (!notification.tracked)
            return;

        root.record(notification);

        if (root.dnd) {
            if (notification.tracked)
                notification.expire();
            return;
        }

        let next = [notification];
        for (const current of root.popups) {
            if (current.id !== notification.id)
                next.push(current);
        }
        root.popups = next;
    }

    // Expiry removes a popup but preserves history; dismissal removes both.
    function removePopup(id) {
        root.popups = root.popups.filter(notification => notification.id !== id);
    }

    function dismiss(notification) {
        root.removeHistory(notification.id);
        root.removePopup(notification.id);
        if (notification.tracked)
            notification.dismiss();
    }

    function removeHistory(id) {
        root.history = root.history.filter(entry => entry.id !== id);
        root.saveState();
    }

    function dismissHistory(id) {
        let notification = root.popups.find(current => current.id === id);
        if (notification)
            root.dismiss(notification);
        else
            root.removeHistory(id);
    }

    function expire(notification) {
        root.removePopup(notification.id);
        notification.expire();
    }

    // DND silences live popups while continuing to record incoming history.
    function setDnd(enabled) {
        if (root.dnd === enabled)
            return;

        root.dnd = enabled;
        if (enabled) {
            let current = root.popups;
            root.popups = [];
            for (const notification of current)
                notification.expire();
        }
        root.saveState();
    }

    function toggleDnd() {
        root.setDnd(!root.dnd);
    }

    function clearHistory() {
        let current = root.popups;
        root.popups = [];
        for (const notification of current) {
            if (notification.tracked)
                notification.dismiss();
        }
        root.history = [];
        root.saveState();
    }

    // Batch disk writes without changing the in-memory model seen by the UI.
    Component.onCompleted: root.loadState()

    Timer {
        id: saveTimer
        interval: 500
        onTriggered: root.writeState()
    }

    FileView {
        id: stateFile
        path: Quickshell.statePath("notifications.json")
        blockLoading: true
        printErrors: false
    }

    // Stable commands for scripts; UI consumers call the same methods directly.
    IpcHandler {
        target: "notifications"

        function toggleDnd(): bool {
            root.toggleDnd();
            return root.dnd;
        }
        function setDnd(enabled: bool): void { root.setDnd(enabled); }
        function clearHistory(): void { root.clearHistory(); }
        function status(): string {
            return JSON.stringify({
                dnd: root.dnd,
                history: root.history.length,
                popups: root.popups.length
            });
        }
    }

    // One desktop notification endpoint, retained across QML reloads.
    NotificationServer {
        actionsSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true
        keepOnReload: true

        onNotification: notification => root.receive(notification)
    }
}
