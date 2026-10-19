import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

// Background surface per output. Aspect-fit keeps the whole wallpaper visible
// on both portrait and landscape displays, with the theme behind letterboxing.
PanelWindow {
    color: Theme.base00
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "quickshell-wallpaper"

    Image {
        anchors.fill: parent
        source: Theme.wallpaper
        fillMode: Image.PreserveAspectFit
        smooth: true
        asynchronous: true
    }
}
