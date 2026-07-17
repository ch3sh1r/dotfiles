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

    implicitWidth: 340
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
            model: server.trackedNotifications

            delegate: Rectangle {
                id: card
                required property var modelData

                function dismiss() {
                    retainer.locked = false;
                    modelData.dismiss();
                }

                width: stack.width
                implicitHeight: body.implicitHeight + 20
                radius: Theme.radius * 2
                color: Theme.base00
                border.width: 1
                border.color: root.borderColor(modelData)

                RetainableLock {
                    id: retainer
                    object: card.modelData
                    locked: true
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
                    onClicked: card.dismiss()
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
                            color: Theme.fg
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
                                            card.dismiss();
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
