import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: root

    visible: server.trackedNotifications.values.length > 0
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

    implicitWidth: 300
    implicitHeight: stack.implicitHeight

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"

    NotificationServer {
        id: server
        actionsSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => {
            notification.tracked = true;
        }
    }

    function notificationColor(notification) {
        if (notification.urgency === NotificationUrgency.Critical)
            return Theme.critical;
        return Theme.base00;
    }

    function foregroundColor(notification) {
        if (notification.urgency === NotificationUrgency.Low)
            return Theme.base03;
        return Theme.fgBright;
    }

    function timeoutMs(notification) {
        if (notification.urgency === NotificationUrgency.Critical)
            return 0;

        let timeout = notification.expireTimeout;
        if (timeout > 0)
            return timeout > 1000 ? timeout : timeout * 1000;

        return 10000;
    }

    Column {
        id: stack
        width: parent.width
        spacing: 6

        Repeater {
            model: server.trackedNotifications

            delegate: Rectangle {
                id: card
                required property var modelData

                width: stack.width
                implicitHeight: body.implicitHeight + 16
                radius: Theme.radius
                color: root.notificationColor(modelData)

                Timer {
                    interval: root.timeoutMs(card.modelData)
                    running: interval > 0
                    repeat: false
                    onTriggered: card.modelData.expire()
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton || card.modelData.actions.length === 0)
                            card.modelData.dismiss();
                    }
                }

                Row {
                    id: body
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 8
                    spacing: 8

                    IconImage {
                        width: 32
                        height: 32
                        visible: source.length > 0
                        source: card.modelData.image.length > 0
                            ? card.modelData.image
                            : Quickshell.iconPath(card.modelData.appIcon, "dialog-information")
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
                            color: card.modelData.urgency === NotificationUrgency.Critical ? Theme.fgBright : Theme.fg
                            wrapMode: Text.Wrap
                            maximumLineCount: 6
                            elide: Text.ElideRight
                            textFormat: Text.RichText
                        }

                        Row {
                            visible: card.modelData.actions.length > 0
                            spacing: 6

                            Repeater {
                                model: card.modelData.actions

                                delegate: Rectangle {
                                    required property var modelData

                                    implicitWidth: actionLabel.implicitWidth + 14
                                    implicitHeight: 22
                                    radius: Theme.radius
                                    color: Theme.base02

                                    Label {
                                        id: actionLabel
                                        anchors.centerIn: parent
                                        text: parent.modelData.text
                                        color: Theme.fgBright
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: parent.modelData.invoke()
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
