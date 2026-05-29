import QtQuick
import Quickshell
import Quickshell.Io

// Tailscale pill. Parses `tailscale status --json` natively. Shows the active
// exit node (if any); the popup lists peers colour-coded by online state.
// Click toggles the tailnet up/down.
Pill {
    id: root

    property bool running: false
    property string exitNode: ""
    property var peers: []

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
                    let list = [];
                    let exit = "";
                    let peerMap = s.Peer || {};
                    for (const key in peerMap) {
                        let p = peerMap[key];
                        let name = (p.DNSName || "").split(".")[0];
                        if (p.ExitNode)
                            exit = name;
                        list.push({
                            name: name,
                            online: !!p.Online,
                            exit: !!p.ExitNode
                        });
                    }
                    list.sort(function (a, b) {
                        return (b.online - a.online) || a.name.localeCompare(b.name);
                    });
                    root.peers = list;
                    root.exitNode = exit;
                } catch (e) {
                    root.running = false;
                    root.peers = [];
                    root.exitNode = "";
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
            spacing: 2

            Label {
                visible: !root.running
                text: "tailscale is not active"
                color: Theme.fg
            }

            Label {
                visible: root.running && root.peers.length === 0
                text: "no peers"
                color: Theme.fg
            }

            Repeater {
                model: root.running ? root.peers : []
                delegate: Label {
                    required property var modelData
                    text: (modelData.exit ? "󰈂 " : "") + modelData.name
                    color: modelData.online ? Theme.good : Theme.critical
                }
            }
        }
    }
}
