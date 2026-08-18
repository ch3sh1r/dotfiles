import QtQuick
import ".."
import "../components"
import "../services"

// Tailscale pill. Parses `tailscale status --json` natively. Shows the active
// exit node (if any); the popup is a compact status summary. Click toggles the
// tailnet up/down.
StatusPill {
    id: root

    icon: root.running ? "󰯉" : "󱩆"
    iconColor: root.running ? Theme.good : Theme.base03
    label: !root.compact && root.running && root.exitNode.length > 0 ? root.exitNode : ""

    property bool compact: false
    readonly property bool running: TailscaleState.running
    readonly property string exitNode: TailscaleState.exitNode
    readonly property string selfName: TailscaleState.selfName
    readonly property string selfIp: TailscaleState.selfIp
    readonly property int peerCount: TailscaleState.peerCount
    readonly property int onlineCount: TailscaleState.onlineCount

    onClicked: TailscaleState.toggle()

    tooltipContent: Column {
        spacing: 4

        // Header: state.
        Row {
            spacing: 6
            IconText {
                text: root.running ? "󰯉" : "󱩆"
                color: root.running ? Theme.good : Theme.base03
            }
            Label {
                text: root.running ? "Connected" : "Stopped"
                color: Theme.fgBright
                font.bold: true
            }
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
