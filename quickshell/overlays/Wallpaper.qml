import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

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
        source: Qt.resolvedUrl("/home/ch3sh1r/.config/hypr/rune.png")
        fillMode: Image.PreserveAspectFit
        smooth: true
        asynchronous: true
    }
}
