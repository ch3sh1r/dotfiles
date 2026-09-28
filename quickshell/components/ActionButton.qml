import QtQuick
import ".."

// Small 24px button. Text buttons get a border; icon-only buttons are square.
Rectangle {
    id: root

    property string text: ""
    property string icon: ""
    property color foreground: Theme.fgBright

    signal clicked()

    implicitWidth: root.text.length > 0 ? label.implicitWidth + 14 : 24
    implicitHeight: 24
    radius: Theme.radius
    color: Theme.base02
    border.width: root.text.length > 0 ? 1 : 0
    border.color: Theme.base03

    IconText {
        anchors.centerIn: parent
        visible: root.text.length === 0
        text: root.icon
        color: root.foreground
    }

    Label {
        id: label
        anchors.centerIn: parent
        visible: root.text.length > 0
        text: root.text
        color: root.foreground
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
