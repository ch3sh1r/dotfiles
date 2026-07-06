import QtQuick
import Quickshell
import Quickshell.Io

// Mullvad VPN pill. Parses `mullvad status --json` natively. Click toggles the
// connection; the tooltip shows where you're exiting. (Region switching was
// dropped — it went unused in the waybar setup.)
Pill {
    id: root

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
                    let s = JSON.parse(this.text.trim());
                    root.connected = s.state === "connected";
                    let loc = (s.details && s.details.location) || {};
                    root.city = loc.city || "";
                    root.country = loc.country || "";
                    root.ip = loc.ipv4 || "";
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

    // Re-poll quickly right after a toggle.
    Timer {
        id: delayed
        interval: 1200
        repeat: false
        onTriggered: root.refresh()
    }

    IconText {
        text: root.connected ? "󰊠" : "󰧵"
        color: root.connected ? Theme.good : Theme.base03
    }

    Label {
        visible: root.connected && root.city.length > 0
        text: root.city
        color: Theme.fgBright
    }

    onClicked: {
        Quickshell.execDetached(["mullvad", root.connected ? "disconnect" : "connect"]);
        delayed.restart();
    }

    Tooltip {
        anchorItem: root
        shown: root.hovered
        text: root.connected ? (root.city + ", " + root.country + "\n" + root.ip) : "Mullvad is not connected"
    }
}
