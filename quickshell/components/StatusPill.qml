import QtQuick
import ".."

// Icon + optional label pill with a click-to-pin tooltip. Left click toggles
// the tooltip; widgets add their own right-click / wheel handlers.
Pill {
    id: root

    property string icon: ""
    property color iconColor: Theme.fg
    property string label: ""
    property bool labelVisible: label.length > 0
    property color labelColor: Theme.fgBright
    property string tooltip: ""
    property alias tooltipPinned: tip.pinned
    property bool tooltipOnHover: false
    property alias tooltipCloseOnClick: tip.closeOnClick
    property alias tooltipContent: tip.content

    function toggleTooltip() {
        tip.togglePinned();
    }

    onClicked: root.toggleTooltip()

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
        shown: tip.pinned || (root.tooltipOnHover && root.hovered)
        closeOnClick: true
        text: root.tooltip
    }
}
