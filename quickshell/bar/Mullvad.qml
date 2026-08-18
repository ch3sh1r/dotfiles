import QtQuick
import Quickshell
import Quickshell.Io
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

    property bool compact: false
    property bool connected: false
    property string city: ""
    property string country: ""
    property string ip: ""

    function refresh() {
        statusProc.running = true;
    }

    Process {
        id: statusProc
        command: ["mullvad", "status", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let status = JSON.parse(this.text.trim());
                    root.connected = status.state === "connected";
                    let location = (status.details && status.details.location) || {};
                    root.city = location.city || "";
                    root.country = location.country || "";
                    root.ip = location.ipv4 || "";
                } catch (e) {
                    root.connected = false;
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

    onClicked: {
        Quickshell.execDetached(["mullvad", root.connected ? "disconnect" : "connect"]);
        delayed.restart();
    }
}
