import QtQuick
import ".."

Pill {
    id: root

    property string icon: ""
    property color iconColor: Theme.fg
    property string label: ""
    property bool labelVisible: label.length > 0
    property color labelColor: Theme.fgBright
    property string tooltip: ""
    property alias tooltipContent: tip.content

    IconText {
        text: root.icon
        color: root.iconColor
    }

    Label {
        visible: root.labelVisible
        text: root.label
        color: root.labelColor
    }

    Tooltip {
        id: tip
        anchorItem: root
        shown: root.hovered
        text: root.tooltip
    }
}
