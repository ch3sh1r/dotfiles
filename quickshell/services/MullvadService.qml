import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool connected: false
    property string state: "disconnected"
    property string city: ""
    property string country: ""
    property string ip: ""
    property string hostname: ""
    property string tunnelInterface: ""
    property string protocol: ""

    function refresh(): void {
        statusProc.running = true;
    }

    function toggle(): void {
        Quickshell.execDetached(["mullvad", root.connected ? "disconnect" : "connect"]);
        delayed.restart();
    }

    Process {
        id: statusProc
        command: ["mullvad", "status", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let status = JSON.parse(this.text.trim());
                    let details = status.details || {};
                    let endpoint = details.endpoint || {};
                    let location = details.location || {};
                    root.state = status.state || "disconnected";
                    root.connected = root.state === "connected";
                    root.city = location.city || "";
                    root.country = location.country || "";
                    root.ip = location.ipv4 || "";
                    root.hostname = location.hostname || "";
                    root.tunnelInterface = details.tunnel_interface || "";
                    root.protocol = endpoint.tunnel_type === "wireguard"
                        ? "WireGuard"
                        : (endpoint.tunnel_type || endpoint.protocol || "");
                } catch (e) {
                    root.connected = false;
                    root.state = "disconnected";
                    root.city = "";
                    root.country = "";
                    root.ip = "";
                    root.hostname = "";
                    root.tunnelInterface = "";
                    root.protocol = "";
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Timer {
        id: delayed
        interval: 1200
        onTriggered: root.refresh()
    }
}
