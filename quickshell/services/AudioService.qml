import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Scope {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property bool muted: audio ? audio.muted : true
    readonly property real volume: audio ? audio.volume : 0
    readonly property int percent: Math.round(volume * 100)
    readonly property bool headphones: {
        if (!sink)
            return false;
        let text = ((sink.description || "") + " " + (sink.nickname || "") + " " + (sink.name || "")).toLowerCase();
        return /head(phone|set)|hands.?free|bluez|a2dp|hifi/.test(text);
    }
    readonly property bool bluetoothHeadphones: {
        if (!sink)
            return false;
        let text = ((sink.description || "") + " " + (sink.nickname || "") + " " + (sink.name || "")).toLowerCase();
        return root.headphones && /bluez|a2dp|hands.?free/.test(text);
    }
    readonly property string sinkInfo: sink ? ((sink.name || "") + " " + (sink.description || "") + " " + (sink.nickname || "")) : ""
    readonly property string batteryScriptPath: Qt.resolvedUrl("../scripts/bluetooth-headset-battery.sh").toString().replace("file://", "")

    property int headsetBattery: -1

    function refreshBattery(): void {
        if (root.bluetoothHeadphones)
            batteryProc.running = true;
        else
            root.headsetBattery = -1;
    }

    function setVolume(volume: real): void {
        if (root.audio)
            root.audio.volume = Math.max(0, Math.min(1, volume));
    }

    function toggleMuted(): void {
        if (root.audio)
            root.audio.muted = !root.audio.muted;
    }

    function openMixer(): void {
        Quickshell.execDetached(["pavucontrol", "-t", "3"]);
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Process {
        id: batteryProc
        command: ["bash", root.batteryScriptPath, root.sinkInfo]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let status = JSON.parse(this.text.trim());
                    root.headsetBattery = status.battery === null ? -1 : status.battery;
                } catch (e) {
                    root.headsetBattery = -1;
                }
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshBattery()
    }

    onSinkInfoChanged: root.refreshBattery()
}
