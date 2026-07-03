import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Pill {
    id: root

    // Keep the default sink bound/awake so its audio props stay live.
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property bool muted: audio ? audio.muted : true
    readonly property real volume: audio ? audio.volume : 0
    readonly property int percent: Math.round(volume * 100)

    readonly property bool headphones: {
        if (!sink)
            return false;
        let s = ((sink.description || "") + " " + (sink.nickname || "") + " " + (sink.name || "")).toLowerCase();
        return /head(phone|set)|hands.?free|bluez|a2dp|hifi/.test(s);
    }
    readonly property bool bluetoothHeadphones: {
        if (!sink)
            return false;
        let s = ((sink.description || "") + " " + (sink.nickname || "") + " " + (sink.name || "")).toLowerCase();
        return root.headphones && /bluez|a2dp|hands.?free/.test(s);
    }
    readonly property string sinkInfo: sink ? ((sink.name || "") + " " + (sink.description || "") + " " + (sink.nickname || "")) : ""
    readonly property string batteryScriptPath: Qt.resolvedUrl("scripts/bluetooth-headset-battery.sh").toString().replace("file://", "")

    property int headsetBattery: -1

    function refreshBattery() {
        if (root.bluetoothHeadphones)
            batteryProc.running = true;
        else
            root.headsetBattery = -1;
    }

    function setVolume(v) {
        if (audio)
            audio.volume = Math.max(0, Math.min(1, v));
    }

    Process {
        id: batteryProc
        command: ["bash", root.batteryScriptPath, root.sinkInfo]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let s = JSON.parse(this.text.trim());
                    root.headsetBattery = s.battery === null ? -1 : s.battery;
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

    IconText {
        text: {
            if (root.muted)
                return "󰖁";
            if (root.headphones)
                return "󰋋";
            if (root.percent <= 0)
                return "󰕿";
            if (root.percent < 50)
                return "󰖀";
            return "󰕾";
        }
        color: root.muted ? Theme.base03 : Theme.fg
    }

    Label {
        text: root.muted ? "" : root.percent
        color: root.muted ? Theme.base03 : Theme.fgBright
    }

    onClicked: if (root.audio) root.audio.muted = !root.audio.muted
    onRightClicked: Quickshell.execDetached(["pavucontrol", "-t", "3"])
    onWheel: function (delta) {
        root.setVolume(root.volume + (delta > 0 ? 0.005 : -0.005));
    }

    Tooltip {
        anchorItem: root
        shown: root.hovered

        Column {
            spacing: 8

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.sink ? (root.sink.description || root.sink.nickname || root.sink.name) : "No sink"
                color: Theme.cyan
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: root.bluetoothHeadphones && root.headsetBattery >= 0
                text: "Battery: " + root.headsetBattery + "%"
                color: Theme.fg
            }

            // Minimal slider.
            Rectangle {
                id: track
                width: 180
                height: 6
                radius: 3
                color: Theme.base02

                Rectangle {
                    height: parent.height
                    radius: parent.radius
                    width: parent.width * root.volume
                    color: root.muted ? Theme.base03 : Theme.accent
                }

                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: Theme.fgBright
                    y: (parent.height - height) / 2
                    x: Math.max(0, Math.min(parent.width - width, parent.width * root.volume - width / 2))
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onPressed: function (m) {
                        root.setVolume(m.x / track.width);
                    }
                    onPositionChanged: function (m) {
                        root.setVolume(m.x / track.width);
                    }
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.muted ? "muted" : root.percent + "%"
                color: Theme.fg
            }
        }
    }
}
