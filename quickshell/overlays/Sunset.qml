import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import ".."

Scope {
    id: root

    property bool applyPending: false
    property int shaderSlot: 0

    function apply(): void {
        if (applyProc.running) {
            root.applyPending = true;
            return;
        }
        root.applyPending = false;
        if (SunsetState.night) {
            // Alternate paths to force recompilation even if only strength changed.
            root.shaderSlot = 1 - root.shaderSlot;
            shaderFile.setText(shaderTemplate.text().replace(
                "const float sunsetIntensity = 0.5;",
                "const float sunsetIntensity = " + SunsetState.intensity.toFixed(4) + ";"));
        } else {
            root.applyConfig("");
        }
    }

    function applyConfig(shader: string): void {
        // Repaint the whole monitor with the screen shader to avoid stale,
        // differently tinted regions. Mode 1 still skips unchanged frames.
        let damageTracking = SunsetState.night ? 1 : 2;
        applyProc.command = ["hyprctl", "eval", "hl.config({ decoration = { screen_shader = " + JSON.stringify(shader) + " }, debug = { damage_tracking = " + damageTracking + " } })"];
        applyProc.running = true;
    }

    FileView {
        id: shaderTemplate
        path: Qt.resolvedUrl("../sunset.frag")
        blockLoading: true
    }

    FileView {
        id: shaderFile
        path: Quickshell.cachePath("sunset-" + root.shaderSlot + ".frag")
        blockWrites: true
        atomicWrites: true
        printErrors: false
        onSaved: root.applyConfig(path)
        onSaveFailed: error => console.error("Cannot write sunset shader: " + FileViewError.toString(error))
    }

    Process {
        id: applyProc
        onExited: {
            if (root.applyPending)
                Qt.callLater(root.apply);
        }
    }

    Timer {
        id: intensityUpdate
        interval: 60
        onTriggered: root.apply()
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
        function toggle(): void { SunsetState.toggle(); }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.update()
    }

    Component.onCompleted: {
        root.update();
        Qt.callLater(root.apply);
    }

    Connections {
        target: SunsetState
        // Coalesce startup changes so a detached day command cannot finish
        // after the night command and overwrite the scheduled state.
        function onNightChanged() { Qt.callLater(root.apply); }
        function onIntensityChanged() {
            if (SunsetState.night && !intensityUpdate.running)
                intensityUpdate.start();
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded")
                Qt.callLater(root.apply);
        }
    }
}
