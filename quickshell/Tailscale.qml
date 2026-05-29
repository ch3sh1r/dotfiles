import QtQuick
import Quickshell
import Quickshell.Io

// Tailscale pill. Parses `tailscale status --json` natively. Shows the active
// exit node (if any); the popup is a compact status summary. Click toggles the
// tailnet up/down.
Pill {
    id: root

    property bool running: false
    property string exitNode: ""
    property string selfName: ""
    property string selfIp: ""
    property int peerCount: 0
    property int onlineCount: 0

    function refresh() {
        statusProc.running = true;
    }

    Process {
        id: statusProc
        command: ["tailscale", "status", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let s = JSON.parse(this.text.trim());
                    root.running = s.BackendState === "Running";

                    let self = s.Self || {};
                    root.selfName = (self.DNSName || "").split(".")[0];
                    root.selfIp = (self.TailscaleIPs && self.TailscaleIPs[0]) || "";

                    let exit = "";
                    let total = 0;
                    let online = 0;
                    let peerMap = s.Peer || {};
                    for (const key in peerMap) {
                        let p = peerMap[key];
                        total += 1;
                        if (p.Online)
                            online += 1;
                        if (p.ExitNode)
                            exit = (p.DNSName || "").split(".")[0];
                    }
                    root.exitNode = exit;
                    root.peerCount = total;
                    root.onlineCount = online;
                } catch (e) {
                    root.running = false;
                    root.exitNode = "";
                    root.selfName = "";
                    root.selfIp = "";
                    root.peerCount = 0;
                    root.onlineCount = 0;
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statusProc.running = true
    }

    Timer {
        id: delayed
        interval: 4000
        repeat: false
        onTriggered: root.refresh()
    }

    IconText {
        text: root.running ? "󰯉" : "󱩆"
        color: root.running ? Theme.good : Theme.base03
    }

    Label {
        visible: root.running && root.exitNode.length > 0
        text: root.exitNode
        color: Theme.fgBright
    }

    onClicked: {
        Quickshell.execDetached(["tailscale", root.running ? "down" : "up"]);
        delayed.restart();
    }

    Tooltip {
        anchorItem: root
        shown: root.hovered

        Column {
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
}
