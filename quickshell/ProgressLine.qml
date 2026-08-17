import QtQuick

Item {
    id: root

    property string title: ""
    property real value: 0

    implicitWidth: 620
    implicitHeight: 20

    function clampedValue() {
        return Math.max(0, Math.min(1, root.value));
    }

    Row {
        anchors.fill: parent
        spacing: 10

        Label {
            width: 104
            anchors.verticalCenter: parent.verticalCenter
            text: root.title
            color: Theme.base04
            font.pixelSize: Theme.menuFontSize
            elide: Text.ElideRight
        }

        Rectangle {
            width: parent.width - 104 - 10 - 42
            height: 8
            anchors.verticalCenter: parent.verticalCenter
            radius: height / 2
            color: Theme.base02

            Rectangle {
                width: parent.width * root.clampedValue()
                height: parent.height
                radius: parent.radius
                color: Theme.purple
            }
        }

        Label {
            width: 42
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(root.clampedValue() * 100) + "%"
            color: Theme.fgBright
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.menuFontSize
        }
    }
}
