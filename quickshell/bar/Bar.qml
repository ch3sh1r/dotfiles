import QtQuick
import Quickshell
import ".."

PanelWindow {
    id: bar

    required property var services
    readonly property bool compact: bar.screen && bar.screen.width < bar.screen.height

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barHeight
    color: Theme.bg

    MouseArea {
        anchors.fill: parent
        onClicked: PopupState.dismiss()
    }

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
        backend: bar.services.clock
        compact: bar.compact
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: Theme.gap
        spacing: Theme.gap

        Volume { backend: bar.services.audio }
        Network {
            backend: bar.services.network
            compact: bar.compact
        }
        Mullvad {
            backend: bar.services.mullvad
            compact: bar.compact
        }
        Tailscale {
            backend: bar.services.tailscale
            compact: bar.compact
        }
        Battery { backend: bar.services.battery }
        // Left click opens recent notifications; right click toggles DND.
        NotificationHistory { backend: bar.services.notifications }
        SunsetToggle {}
        OrientationLock {
            backend: bar.services.orientation
            monitorName: bar.screen ? bar.screen.name : ""
        }
    }
}
