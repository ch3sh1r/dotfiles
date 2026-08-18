import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."

Scope {
    id: root

    function update(): void {
        let now = new Date();
        let minutes = now.getHours() * 60 + now.getMinutes();
        let scheduledNight = minutes < 480 || minutes >= 1200;

        if (SunsetState.scheduledNight !== scheduledNight) {
            SunsetState.scheduledNight = scheduledNight;
            SunsetState.togglePinned = false;
        }

        if (!SunsetState.togglePinned)
            SunsetState.night = scheduledNight;
    }

    IpcHandler {
        target: "sunset"

        function day(): void { SunsetState.togglePinned = true; SunsetState.night = false; }
        function night(): void { SunsetState.togglePinned = true; SunsetState.night = true; }
        function toggle(): void { SunsetState.togglePinned = true; SunsetState.night = !SunsetState.night; }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.update()
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            visible: SunsetState.night
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            mask: Region { width: 0; height: 0 }

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.namespace: "quickshell-sunset"

            Rectangle {
                anchors.fill: parent
                color: Theme.sunsetTint
            }
        }
    }
}
