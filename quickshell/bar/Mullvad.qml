import QtQuick
import ".."
import "../components"

// Mullvad VPN pill. Parses `mullvad status --json` natively. Right-click
// toggles the connection; left-click shows where you're exiting.
StatusPill {
    id: root

    icon: root.connected ? "󰊠" : "󰧵"
    iconColor: root.connected ? Theme.good : Theme.base03
    label: !root.compact && root.connected && root.city.length > 0 ? root.city : ""

    required property var backend
    property bool compact: false
    readonly property bool connected: backend.connected
    // Not `state`: that would shadow Item.state.
    readonly property string vpnState: backend.state
    readonly property string city: backend.city
    readonly property string country: backend.country
    readonly property string ip: backend.ip
    readonly property string hostname: backend.hostname
    readonly property string tunnelInterface: backend.tunnelInterface
    readonly property string protocol: backend.protocol

    function stateLabel() {
        if (root.connected)
            return "Connected";
        if (root.vpnState === "connecting")
            return "Connecting";
        if (root.vpnState === "disconnecting")
            return "Disconnecting";
        return "Disconnected";
    }

    onRightClicked: backend.toggle()

    tooltipContent: Column {
        spacing: 4

        TooltipHeader {
            icon: root.icon
            iconColor: root.iconColor
            text: root.stateLabel()
        }

        Label {
            visible: root.connected && root.city.length > 0
            text: root.city + (root.country.length > 0 ? ", " + root.country : "")
            color: Theme.fg
        }

        Label {
            visible: root.connected && root.ip.length > 0
            text: "Exit: " + root.ip + (root.hostname.length > 0 ? "  ·  " + root.hostname : "")
            color: Theme.fg
        }

        Label {
            visible: root.connected && (root.protocol.length > 0 || root.tunnelInterface.length > 0)
            text: "Tunnel: " + [root.protocol, root.tunnelInterface].filter(value => value.length > 0).join("  ·  ")
            color: Theme.fg
        }
    }
}
