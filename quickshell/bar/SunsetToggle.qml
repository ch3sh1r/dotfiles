import QtQuick
import ".."
import "../components"

StatusPill {
    id: root

    visible: SunsetState.scheduledNight || SunsetState.night || SunsetState.togglePinned
    icon: SunsetState.night ? "" : "󰖨"
    tooltip: SunsetState.night ? "Return to normal colors" : "Use sunset colors"

    onClicked: {
        SunsetState.togglePinned = true;
        SunsetState.night = !SunsetState.night;
    }
}
