import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import ".."

Scope {
    id: root

    function apply(): void {
        let shader = SunsetState.night ? Qt.resolvedUrl("../sunset.frag").toString().replace("file://", "") : "";
        Quickshell.execDetached(["hyprctl", "eval", "hl.config({ decoration = { screen_shader = " + JSON.stringify(shader) + " } })"]);
    }

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

    Component.onCompleted: root.apply()

    Connections {
        target: SunsetState
        function onNightChanged() { root.apply(); }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded")
                root.apply();
        }
    }
}
