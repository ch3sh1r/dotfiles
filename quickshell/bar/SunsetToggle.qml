import QtQuick
import ".."
import "../components"

StatusPill {
    id: root

    visible: SunsetState.scheduledNight || SunsetState.night || SunsetState.togglePinned
    icon: SunsetState.night ? "" : "󰖨"
    iconColor: SunsetState.night ? Theme.fg : Theme.base03
    tooltipCloseOnClick: false

    onRightClicked: SunsetState.toggle()

    tooltipContent: Column {
        spacing: 8

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Night mode"
            color: Theme.cyan
        }

        Rectangle {
            id: track
            width: 180
            height: 6
            radius: 3
            color: Theme.base02

            Rectangle {
                height: parent.height
                radius: parent.radius
                width: parent.width * SunsetState.intensity
                color: SunsetState.night ? Theme.accent : Theme.base03
            }

            Rectangle {
                width: 12
                height: 12
                radius: 6
                color: Theme.fgBright
                y: (parent.height - height) / 2
                x: Math.max(0, Math.min(parent.width - width, parent.width * SunsetState.intensity - width / 2))
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6

                function adjust(mouseX: real): void {
                    SunsetState.setIntensity((mouseX + x) / track.width);
                }

                onPressed: m => adjust(m.x)
                onPositionChanged: m => {
                    if (pressed)
                        adjust(m.x);
                }
            }
        }

        ActionButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: SunsetState.night ? "Turn off" : "Turn on"
            onClicked: SunsetState.toggle()
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Intensity: " + Math.round(SunsetState.intensity * 100) + "%"
            color: Theme.fg
        }
    }
}
