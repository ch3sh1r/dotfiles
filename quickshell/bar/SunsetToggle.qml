import QtQuick
import ".."
import "../components"

StatusPill {
    id: root

    visible: SunsetState.scheduledNight || SunsetState.night || SunsetState.togglePinned
    icon: SunsetState.night ? "" : "󰖨"
    tooltipCloseOnClick: true
    tooltip: SunsetState.night ? "Return to normal colors" : "Use sunset colors"

    onClicked: root.toggleTooltip()
    onRightClicked: {
        SunsetState.togglePinned = true;
        SunsetState.night = !SunsetState.night;
    }
}
