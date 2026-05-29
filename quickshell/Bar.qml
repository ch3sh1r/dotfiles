import QtQuick
import Quickshell

// Top bar. Mirrors the waybar layout:
//   left  : Hyprland workspaces
//   center: clock
//   right : volume, network, mullvad, tailscale, battery
PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barHeight
    color: Theme.bg

    // left
    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Theme.gap
        spacing: Theme.gap

        Workspaces {
            monitorName: bar.screen ? bar.screen.name : ""
        }
    }

    // center
    Clock {
        anchors.centerIn: parent
    }

    // right
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
    }
}
