import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Volume and brightness keys, arriving as Hyprland global shortcuts
// (hl.dsp.global("quickshell:<name>") in hypr/modules/bindings.lua). Volume is
// set straight on the Pipewire node, brightness with one brightnessctl call,
// and both end in the OSD. Nothing is spawned per keypress for audio.
Scope {
    id: root

    required property var audio
    required property var osd

    readonly property real step: 0.05
    readonly property real fineStep: 0.01

    function volumeIcon(): string {
        if (root.audio.muted || root.audio.percent <= 0)
            return "volume-muted";
        if (root.audio.percent < 34)
            return "volume-low";
        if (root.audio.percent < 67)
            return "volume-medium";
        return "volume-high";
    }

    function showVolume(): void {
        root.osd.show(root.volumeIcon(), root.audio.percent);
    }

    function adjustVolume(delta: real): void {
        if (!root.audio.audio)
            return;
        root.audio.setVolume(root.audio.volume + delta);
        // Turning the knob means "I want to hear it".
        root.audio.setMuted(false);
        root.showVolume();
    }

    function toggleMute(): void {
        root.audio.toggleMuted();
        root.showVolume();
    }

    function toggleMicMute(): void {
        root.audio.toggleSourceMuted();
        if (root.audio.sourceMuted)
            root.osd.showMessage("microphone-muted", "Microphone muted");
        else
            root.osd.showMessage("microphone", "Microphone on");
    }

    // Drop a press that overlaps one still being applied, so key repeat cannot
    // race the writes.
    function setBrightness(spec: string): void {
        if (brightnessProc.running)
            return;
        brightnessProc.command = ["brightnessctl", "-m", "s", spec];
        brightnessProc.running = true;
    }

    function showBrightness(text: string): void {
        // Machine-readable line: device,class,current,percent%,max
        let lines = String(text).trim().split("\n");
        let fields = lines[lines.length - 1].split(",");
        let percent = parseInt((fields[3] || "").replace("%", ""), 10);
        if (!isNaN(percent))
            root.osd.show("brightness", percent);
    }

    Process {
        id: brightnessProc
        stdout: StdioCollector {
            onStreamFinished: root.showBrightness(text)
        }
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "volume-raise"
        description: "Volume up"
        onPressed: root.adjustVolume(root.step)
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "volume-lower"
        description: "Volume down"
        onPressed: root.adjustVolume(-root.step)
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "volume-raise-fine"
        description: "Volume up 1%"
        onPressed: root.adjustVolume(root.fineStep)
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "volume-lower-fine"
        description: "Volume down 1%"
        onPressed: root.adjustVolume(-root.fineStep)
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "volume-mute"
        description: "Toggle mute"
        onPressed: root.toggleMute()
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "mic-mute"
        description: "Toggle microphone mute"
        onPressed: root.toggleMicMute()
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "brightness-raise"
        description: "Brightness up"
        onPressed: root.setBrightness("5%+")
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "brightness-lower"
        description: "Brightness down"
        onPressed: root.setBrightness("5%-")
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "brightness-raise-fine"
        description: "Brightness up 1%"
        onPressed: root.setBrightness("1%+")
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "brightness-lower-fine"
        description: "Brightness down 1%"
        onPressed: root.setBrightness("1%-")
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "brightness-max"
        description: "Brightness maximum"
        onPressed: root.setBrightness("100%")
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "brightness-min"
        description: "Brightness minimum"
        onPressed: root.setBrightness("1%")
    }
}
