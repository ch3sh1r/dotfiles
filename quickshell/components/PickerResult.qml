import QtQuick
import Quickshell
import Quickshell.Widgets
import ".."

// A picker row renders describe(item)'s result and reports pointer interaction.
// Model access, keyboard navigation and selection belong to PickerWindow.
Rectangle {
    id: row

    required property var info
    required property bool selected

    signal hovered()
    signal activated()

    height: 44
    radius: Theme.radius
    color: row.selected ? Theme.base02 : "transparent"

    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10

        Item {
            id: leading
            width: 24
            height: 24
            anchors.verticalCenter: parent.verticalCenter

            IconImage {
                anchors.fill: parent
                visible: !!row.info.icon
                source: row.info.icon ? Quickshell.iconPath(row.info.icon, "application-x-executable") : ""
            }

            IconText {
                anchors.centerIn: parent
                visible: !row.info.icon
                text: row.info.glyph || ""
                color: Theme.base04
            }
        }

        Column {
            width: parent.width - leading.width - parent.spacing
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Label {
                width: parent.width
                text: row.info.title || ""
                color: Theme.fgBright
                font.pixelSize: Theme.menuFontSize
                elide: Text.ElideRight
            }

            Label {
                width: parent.width
                visible: (row.info.subtitle || "").length > 0
                text: row.info.subtitle || ""
                color: Theme.base04
                font.pixelSize: Theme.menuFontSize
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: row.hovered()
        onClicked: row.activated()
    }
}
