import QtQuick
import ".."

// Floating surfaces can appear above the fullscreen sunset layer.
// Tint their content locally without intercepting pointer input.
Rectangle {
    anchors.fill: parent
    z: 100
    visible: SunsetState.night
    color: Theme.sunsetTint
}
