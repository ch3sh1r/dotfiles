import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets
import ".."
import "../components"

PanelWindow {
    id: root

    required property var backend

    visible: backend.popups.length > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
    }

    margins {
        top: 50
        right: 10
    }

    implicitWidth: 340
    implicitHeight: stack.implicitHeight

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"

    function timeoutMs(notification) {
        if (notification.urgency === NotificationUrgency.Critical || notification.expireTimeout === 0)
            return 0;
        if (notification.expireTimeout > 0)
            return Math.round(notification.expireTimeout);
        return 7000;
    }

    function defaultAction(notification) {
        for (const action of notification.actions) {
            if (action.identifier === "default")
                return action;
        }
        return null;
    }

    function visibleActions(notification) {
        let actions = [];
        for (const action of notification.actions) {
            if (action.identifier !== "default")
                actions.push(action);
        }
        return actions;
    }

    function activate(notification) {
        let action = root.defaultAction(notification);
        if (!action) {
            root.backend.dismiss(notification);
            return;
        }

        action.invoke();
        if (!notification.resident)
            root.backend.removePopup(notification.id);
    }

    function accentColor(notification) {
        if (notification.urgency === NotificationUrgency.Critical)
            return Theme.critical;
        if (notification.urgency === NotificationUrgency.Low)
            return Theme.base03;
        return Theme.accent;
    }

    function borderColor(notification) {
        if (notification.urgency === NotificationUrgency.Critical)
            return Theme.critical;
        return Theme.base02;
    }

    function foregroundColor(notification) {
        if (notification.urgency === NotificationUrgency.Low)
            return Theme.base03;
        return Theme.fgBright;
    }

    Column {
        id: stack
        width: parent.width
        spacing: 8

        Repeater {
            model: root.backend.popups

            delegate: Rectangle {
                id: card
                required property var modelData

                width: stack.width
                implicitHeight: body.implicitHeight + 20
                radius: Theme.radius * 2
                color: Theme.base00
                border.width: 1
                border.color: root.borderColor(card.modelData)

                RetainableLock {
                    object: card.modelData
                    locked: true
                }

                Connections {
                    target: card.modelData

                    function onClosed(reason) {
                        root.backend.removePopup(card.modelData.id);
                    }
                }

                Timer {
                    interval: Math.max(1, root.timeoutMs(card.modelData))
                    running: root.timeoutMs(card.modelData) > 0
                    onTriggered: root.backend.expire(card.modelData)
                }

                Rectangle {
                    width: 4
                    radius: 2
                    color: root.accentColor(card.modelData)
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 1
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: function (mouse) {
                        if (mouse.button === Qt.RightButton)
                            root.backend.dismiss(card.modelData);
                        else
                            root.activate(card.modelData);
                    }
                }

                Row {
                    id: body
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 14
                    anchors.rightMargin: 10
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10
                    spacing: 10

                    IconImage {
                        width: 32
                        height: 32
                        visible: source.length > 0
                        source: card.modelData.image.length > 0
                            ? card.modelData.image
                            : (card.modelData.appIcon.length > 0 ? Quickshell.iconPath(card.modelData.appIcon) : "")
                    }

                    Column {
                        width: parent.width - (parent.children[0].visible ? 40 : 0)
                        spacing: 4

                        Label {
                            width: parent.width
                            text: card.modelData.summary
                            color: root.foregroundColor(card.modelData)
                            font.bold: true
                            elide: Text.ElideMiddle
                        }

                        Label {
                            width: parent.width
                            visible: card.modelData.body.length > 0
                            text: card.modelData.body
                            color: Theme.fg
                            wrapMode: Text.Wrap
                            maximumLineCount: 6
                            elide: Text.ElideRight
                            textFormat: Text.RichText
                        }

                        Row {
                            visible: root.visibleActions(card.modelData).length > 0
                            spacing: 6

                            Repeater {
                                model: root.visibleActions(card.modelData)

                                delegate: Rectangle {
                                    required property var modelData

                                    implicitWidth: actionLabel.implicitWidth + 14
                                    implicitHeight: 24
                                    radius: Theme.radius
                                    color: Theme.base02
                                    border.width: 1
                                    border.color: Theme.base03

                                    Label {
                                        id: actionLabel
                                        anchors.centerIn: parent
                                        text: parent.modelData.text
                                        color: Theme.fgBright
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            parent.modelData.invoke();
                                            if (!card.modelData.resident)
                                                root.backend.removePopup(card.modelData.id);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
