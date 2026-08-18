pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
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

    function toggle() {
        Quickshell.execDetached(["tailscale", root.running ? "down" : "up"]);
        delayed.restart();
    }

    property Process statusProc: Process {
        command: ["tailscale", "status", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let status = JSON.parse(this.text.trim());
                    root.running = status.BackendState === "Running";

                    let self = status.Self || {};
                    root.selfName = (self.DNSName || "").split(".")[0];
                    root.selfIp = (self.TailscaleIPs && self.TailscaleIPs[0]) || "";

                    let exit = "";
                    let total = 0;
                    let online = 0;
                    let peers = status.Peer || {};
                    for (const key in peers) {
                        let peer = peers[key];
                        total += 1;
                        if (peer.Online)
                            online += 1;
                        if (peer.ExitNode)
                            exit = (peer.DNSName || "").split(".")[0];
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

    property Timer pollTimer: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    property Timer delayed: Timer {
        interval: 4000
        onTriggered: root.refresh()
    }
}
