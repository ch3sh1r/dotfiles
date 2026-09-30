import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import ".."
import "../components"

Scope {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property bool muted: audio ? audio.muted : true
    readonly property real volume: audio ? audio.volume : 0
    readonly property int percent: Math.round(volume * 100)
    readonly property string sinkText: sink ? ((sink.description || "") + " " + (sink.nickname || "") + " " + (sink.name || "")).toLowerCase() : ""
    readonly property bool bluetoothHeadphones: /bluez|a2dp|hands.?free/.test(sinkText)
    // Not "hifi": ALSA UCM names built-in speakers "...HiFi__Speaker__sink".
    readonly property bool headphones: bluetoothHeadphones || /head(phone|set)/.test(sinkText)
    readonly property string sinkInfo: sink ? ((sink.name || "") + " " + (sink.description || "") + " " + (sink.nickname || "")) : ""

    readonly property var source: Pipewire.defaultAudioSource
    readonly property var sourceAudio: source ? source.audio : null
    readonly property bool sourceMuted: sourceAudio ? sourceAudio.muted : true

    property int headsetBattery: -1

    function setVolume(volume: real): void {
        if (root.audio)
            root.audio.volume = Math.max(0, Math.min(1, volume));
    }

    function setMuted(muted: bool): void {
        if (root.audio && root.audio.muted !== muted)
            root.audio.muted = muted;
    }

    function toggleMuted(): void {
        if (root.audio)
            root.audio.muted = !root.audio.muted;
    }

    function toggleSourceMuted(): void {
        if (root.sourceAudio)
            root.sourceAudio.muted = !root.sourceAudio.muted;
    }

    function openMixer(): void {
        Quickshell.execDetached(["uwsm", "app", "--", "pavucontrol", "-t", "3"]);
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    JsonPoller {
        id: batteryPoller
        command: ["bash", Theme.scriptPath("bluetooth-headset-battery.sh"), root.sinkInfo]
        interval: 30000
        active: root.bluetoothHeadphones

        onParsed: status => root.headsetBattery = typeof status.battery === "number" ? status.battery : -1
        onFailed: root.headsetBattery = -1
    }

    onBluetoothHeadphonesChanged: {
        if (!root.bluetoothHeadphones)
            root.headsetBattery = -1;
    }
    onSinkInfoChanged: {
        if (root.bluetoothHeadphones)
            batteryPoller.refresh();
    }
}
