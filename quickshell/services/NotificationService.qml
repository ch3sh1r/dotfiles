import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Scope {
    id: root

    readonly property int historyLimit: 10
    property bool dnd: false
    property var popups: []
    property var history: []

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

    function saveState() {
        stateFile.setText(JSON.stringify({
            dnd: root.dnd,
            history: root.history
        }, null, 2) + "\n");
    }

    function snapshot(notification) {
        return {
            id: notification.id,
            appName: notification.appName,
            appIcon: notification.appIcon,
            summary: notification.summary,
            body: notification.body,
            image: notification.image,
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
        notification.closed.connect(reason => root.removePopup(notification.id));

        root.refresh(notification);
    }

    function refresh(notification) {
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

    function removePopup(id) {
        root.popups = root.popups.filter(notification => notification.id !== id);
    }

    function dismiss(notification) {
        root.removePopup(notification.id);
        notification.dismiss();
    }

    function expire(notification) {
        root.removePopup(notification.id);
        notification.expire();
    }

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
        root.history = [];
        root.saveState();
    }

    Component.onCompleted: root.loadState()

    FileView {
        id: stateFile
        path: Quickshell.statePath("notifications.json")
        blockLoading: true
        printErrors: false
    }

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

    NotificationServer {
        actionsSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true
        keepOnReload: true

        onNotification: notification => root.receive(notification)
    }
}
