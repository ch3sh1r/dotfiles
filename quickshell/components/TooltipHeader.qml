import QtQuick
import ".."

// Icon + bold title row at the top of a status tooltip.
Row {
    id: root

    property string icon: ""
    property color iconColor: Theme.fg
    property string text: ""

    spacing: 6

    IconText {
        text: root.icon
        color: root.iconColor
    }

    Label {
        text: root.text
        color: Theme.fgBright
        font.bold: true
    }
}
