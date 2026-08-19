import QtQuick
import ".."
import "../components"

// Mullvad VPN pill. Parses `mullvad status --json` natively. Click toggles the
// connection; the tooltip shows where you're exiting. (Region switching was
// dropped — it went unused in the waybar setup.)
StatusPill {
    id: root

    icon: root.connected ? "󰊠" : "󰧵"
    iconColor: root.connected ? Theme.good : Theme.base03
    label: !root.compact && root.connected && root.city.length > 0 ? root.city : ""
    tooltip: root.connected ? (root.city + ", " + root.country + "\n" + root.ip) : "Mullvad is not connected"

    required property var backend
    property bool compact: false
    readonly property bool connected: backend.connected
    readonly property string city: backend.city
    readonly property string country: backend.country
    readonly property string ip: backend.ip

    onClicked: backend.toggle()
}
