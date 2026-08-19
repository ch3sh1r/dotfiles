import QtQuick
import ".."
import "../components"

StatusPill {
    id: root

    icon: {
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
    iconColor: root.muted ? Theme.base03 : Theme.fg
    label: root.muted ? "" : root.percent
    labelVisible: true

    required property var backend
    readonly property var sink: backend.sink
    readonly property var audio: backend.audio
    readonly property bool muted: backend.muted
    readonly property real volume: backend.volume
    readonly property int percent: backend.percent
    readonly property bool headphones: backend.headphones
    readonly property bool bluetoothHeadphones: backend.bluetoothHeadphones
    readonly property int headsetBattery: backend.headsetBattery

    onClicked: backend.toggleMuted()
    onRightClicked: backend.openMixer()
    onWheel: function (delta) {
        backend.setVolume(root.volume + (delta > 0 ? 0.005 : -0.005));
    }

    tooltipContent: Column {
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
                    backend.setVolume(m.x / track.width);
                }
                onPositionChanged: function (m) {
                    backend.setVolume(m.x / track.width);
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
