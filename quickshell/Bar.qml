import QtQuick
import Quickshell

PanelWindow {
    id: bar

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
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: Theme.gap
        spacing: Theme.gap

        Volume {}
        Network {}
        Mullvad {}
        Tailscale {}
        Battery {}
        OrientationLock {
            monitorName: bar.screen ? bar.screen.name : ""
        }
    }
}
