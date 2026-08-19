import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool connected: false
    property string city: ""
    property string country: ""
    property string ip: ""

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
}
