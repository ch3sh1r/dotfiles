import QtQuick
import Quickshell
import ".."

PanelWindow {
    id: bar

    readonly property bool compactClock: bar.screen && bar.screen.width < bar.screen.height

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barHeight
    color: Theme.bg

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Theme.gap
        spacing: Theme.gap

        Workspaces {
            monitorName: bar.screen ? bar.screen.name : ""
        }
    }

    Clock {
        anchors.centerIn: parent
        compact: bar.compactClock
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: Theme.gap
        spacing: Theme.gap

        Volume {}
        Network {
            compact: bar.compactClock
        }
        Mullvad {
            compact: bar.compactClock
        }
        Tailscale {}
        Battery {}
        SunsetToggle {}
        OrientationLock {
            monitorName: bar.screen ? bar.screen.name : ""
        }
    }
}
