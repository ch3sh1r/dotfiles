import QtQuick
import Quickshell
import Quickshell.Wayland

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
        source: "file:///home/ch3sh1r/.config/hypr/rune.png"
        fillMode: Image.PreserveAspectFit
        smooth: true
        asynchronous: true
    }
}
