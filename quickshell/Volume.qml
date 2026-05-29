import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Volume pill backed directly by PipeWire — no wpctl polling. Scroll to change,
// click to mute, right-click opens pavucontrol. The popup shows the device and
// a live slider.
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

    function setVolume(v) {
        if (audio)
            audio.volume = Math.max(0, Math.min(1, v));
    }

    Label {
        text: root.muted ? "muted" : root.percent + "%"
        color: root.muted ? Theme.base03 : Theme.fgBright
    }

    IconText {
        text: {
            if (root.muted)
                return "󰖁"; // 󰝟  muted
            if (root.percent <= 0)
                return "󰕺"; // 󰝚  off
            if (root.percent < 50)
                return "󰖀"; // 󰝀  low
            return "󰕾";     // 󰝾  high
        }
        color: root.muted ? Theme.base03 : Theme.fg
    }

    onClicked: if (root.audio) root.audio.muted = !root.audio.muted
    onRightClicked: Quickshell.execDetached(["pavucontrol", "-t", "3"])
    onWheel: function (delta) {
        root.setVolume(root.volume + (delta > 0 ? 0.05 : -0.05));
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
