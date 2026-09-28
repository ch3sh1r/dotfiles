import QtQuick
import Quickshell.Services.Notifications
import ".."
import "../components"

Pill {
    id: root

    required property var backend

    onClicked: historyPopup.togglePinned()
    onRightClicked: root.backend.toggleDnd()

    IconText {
        text: root.backend.dnd ? "󰥳" : ""
        color: root.backend.dnd ? Theme.warning : Theme.fg
    }

    Label {
        visible: root.backend.history.length > 0
        text: root.backend.history.length
        color: Theme.fgBright
    }

    Tooltip {
        id: historyPopup
        anchorItem: root
        framed: true

        Column {
            id: panel
            width: Theme.notificationHistoryWidth
            spacing: 8

            Row {
                width: panel.width
                spacing: 6

                Label {
                    width: panel.width - dndButton.width - clearButton.width - parent.spacing * 2
                    text: "Notifications"
                    color: Theme.fgBright
                    font.bold: true
                    font.pixelSize: Theme.menuTitleFontSize
                }

                ActionButton {
                    id: dndButton
                    icon: root.backend.dnd ? "󰂛" : "󰂚"
                    color: root.backend.dnd ? Theme.warning : Theme.base02
                    foreground: root.backend.dnd ? Theme.base00 : Theme.fgBright
                    onClicked: root.backend.toggleDnd()
                }

                ActionButton {
                    id: clearButton
                    icon: "󰆴"
                    onClicked: {
                        root.backend.clearHistory();
                        historyPopup.dismiss();
                    }
                }
            }

            Label {
                width: panel.width
                visible: root.backend.history.length === 0
                text: "All caught up"
                color: Theme.base03
                horizontalAlignment: Text.AlignHCenter
            }

            ListView {
                id: historyList
                width: panel.width
                implicitHeight: root.backend.history.length > 0 ? Math.min(contentHeight, 480) : 0
                height: implicitHeight
                visible: root.backend.history.length > 0
                clip: true
                spacing: 6
                model: root.backend.history

                delegate: Rectangle {
                    id: historyCard
                    required property var modelData

                    width: historyList.width
                    implicitHeight: historyBody.implicitHeight + 16
                    radius: Theme.radius
                    color: Theme.base01
                    border.width: 1
                    border.color: modelData.urgency === NotificationUrgency.Critical ? Theme.critical : Theme.base02

                    NotificationCard {
                        id: historyBody
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 8
                        iconSize: 24
                        bodyLines: 3
                        image: historyCard.modelData.image || ""
                        appIcon: historyCard.modelData.appIcon || ""
                        summary: historyCard.modelData.summary || ""
                        body: historyCard.modelData.body || ""
                        timeText: Qt.formatDateTime(new Date(historyCard.modelData.timestamp), "HH:mm")
                    }
                }
            }
        }
    }
}
