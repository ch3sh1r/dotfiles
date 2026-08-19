import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import ".."
import "../components"

Pill {
    id: root

    required property var backend
    property bool pinned: false

    onClicked: root.pinned = !root.pinned
    onRightClicked: root.backend.toggleDnd()

    IconText {
        text: root.backend.dnd ? "󰥳" : ""
        color: root.backend.dnd ? Theme.warning : Theme.fg
    }

    Label {
        visible: root.backend.history.length > 0
        text: root.backend.history.length
        color: Theme.fgBright
    }

    Tooltip {
        anchorItem: root
        shown: root.pinned
        frameRadius: Theme.radius * 2
        frameBorderWidth: 1
        frameBorderColor: Theme.base02

        Column {
            id: panel
            width: 320
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

                Rectangle {
                    id: dndButton
                    implicitWidth: 24
                    implicitHeight: 24
                    radius: Theme.radius
                    color: root.backend.dnd ? Theme.warning : Theme.base02

                    IconText {
                        anchors.centerIn: parent
                        text: root.backend.dnd ? "󰂛" : "󰂚"
                        color: root.backend.dnd ? Theme.base00 : Theme.fgBright
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.backend.toggleDnd()
                    }
                }

                Rectangle {
                    id: clearButton
                    implicitWidth: 24
                    implicitHeight: 24
                    radius: Theme.radius
                    color: Theme.base02

                    IconText {
                        anchors.centerIn: parent
                        text: "󰆴"
                        color: Theme.fgBright
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.backend.clearHistory()
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

                    Row {
                        id: historyBody
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 8
                        spacing: 8

                        IconImage {
                            width: 24
                            height: 24
                            visible: source.length > 0
                            source: historyCard.modelData.image.length > 0
                                ? historyCard.modelData.image
                                : (historyCard.modelData.appIcon.length > 0 ? Quickshell.iconPath(historyCard.modelData.appIcon) : "")
                        }

                        Column {
                            width: parent.width - (parent.children[0].visible ? 32 : 0)
                            spacing: 3

                            Row {
                                width: parent.width

                                Label {
                                    width: parent.width - historyTime.width - 8
                                    text: historyCard.modelData.summary
                                    color: Theme.fgBright
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Label {
                                    id: historyTime
                                    text: Qt.formatDateTime(new Date(historyCard.modelData.timestamp), "HH:mm")
                                    color: Theme.base03
                                }
                            }

                            Label {
                                width: parent.width
                                visible: historyCard.modelData.body.length > 0
                                text: historyCard.modelData.body
                                color: Theme.fg
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                textFormat: Text.RichText
                            }
                        }
                    }
                }
            }
        }
    }
}
