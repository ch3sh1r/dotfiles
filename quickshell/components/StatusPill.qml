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
    property bool tooltipPinned: false
    property bool tooltipOnHover: false
    property alias tooltipCloseOnClick: tip.closeOnClick
    property alias tooltipContent: tip.content

    function toggleTooltip() {
        let shouldShow = !root.tooltipPinned;
        PopupState.dismiss();
        root.tooltipPinned = shouldShow;
    }

    Connections {
        target: PopupState
        function onDismissRequested() {
            root.tooltipPinned = false;
        }
    }

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
        shown: root.tooltipPinned || (root.tooltipOnHover && root.hovered)
        text: root.tooltip
        onDismissRequested: root.tooltipPinned = false
    }
}
