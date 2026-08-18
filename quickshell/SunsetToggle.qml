import QtQuick

Pill {
    id: root

    visible: SunsetState.night

    IconText {
        text: SunsetState.night ? "" : "󰖨"
        color: SunsetState.night ? Theme.warning : Theme.fg
    }

    onClicked: SunsetState.night = !SunsetState.night

    Tooltip {
        anchorItem: root
        shown: root.hovered
        text: SunsetState.night ? "Return to normal colors" : "Use sunset colors"
    }
}
