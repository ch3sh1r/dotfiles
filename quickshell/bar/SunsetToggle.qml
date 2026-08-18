import QtQuick
import ".."
import "../components"

Pill {
    id: root

    visible: SunsetState.scheduledNight || SunsetState.night || SunsetState.togglePinned

    IconText {
        text: SunsetState.night ? "" : "󰖨"
        color: Theme.fg
    }

    onClicked: {
        SunsetState.togglePinned = true;
        SunsetState.night = !SunsetState.night;
    }

    Tooltip {
        anchorItem: root
        shown: root.hovered
        text: SunsetState.night ? "Return to normal colors" : "Use sunset colors"
    }
}
