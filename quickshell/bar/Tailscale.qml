import QtQuick
import ".."
import "../components"

// Tailscale pill. Parses `tailscale status --json` natively. Shows the active
// exit node (if any); the popup is a compact status summary. Right-click
// toggles the tailnet up/down.
StatusPill {
    id: root

    icon: root.running ? "󰯉" : "󱩆"
    iconColor: root.running ? Theme.good : Theme.base03
    label: !root.compact && root.running && root.exitNode.length > 0 ? root.exitNode : ""

    required property var backend
    property bool compact: false
    readonly property bool running: backend.running
    readonly property string exitNode: backend.exitNode
    readonly property string selfName: backend.selfName
    readonly property string selfIp: backend.selfIp
    readonly property int peerCount: backend.peerCount
    readonly property int onlineCount: backend.onlineCount

    onRightClicked: backend.toggle()

    tooltipContent: Column {
        spacing: 4

        TooltipHeader {
            icon: root.icon
            iconColor: root.iconColor
            text: root.running ? "Connected" : "Stopped"
        }

        Label {
            visible: root.running && root.selfName.length > 0
            text: root.selfName + (root.selfIp.length > 0 ? "  ·  " + root.selfIp : "")
            color: Theme.fg
        }

        Label {
            visible: root.running
            text: "Exit node: " + (root.exitNode.length > 0 ? root.exitNode : "none")
            color: Theme.fg
        }

        Label {
            visible: root.running
            text: "Peers: " + root.onlineCount + "/" + root.peerCount + " online"
            color: Theme.fg
        }
    }
}
