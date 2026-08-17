import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    property bool night: false

    function update(): void {
        let now = new Date();
        let minutes = now.getHours() * 60 + now.getMinutes();
        root.night = minutes < 480 || minutes >= 1200;
    }

    IpcHandler {
        target: "sunset"

        function day(): void { root.night = false; }
        function night(): void { root.night = true; }
        function toggle(): void { root.night = !root.night; }
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
            visible: root.night
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
                color: "#14ff9f5f"
            }

            Rectangle {
                anchors.fill: parent
                color: "#0f000000"
            }
        }
    }
}
