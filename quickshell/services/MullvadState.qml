pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool connected: false
    property string city: ""
    property string country: ""
    property string ip: ""

    function refresh() {
        statusProc.running = true;
    }

    function toggle() {
        Quickshell.execDetached(["mullvad", root.connected ? "disconnect" : "connect"]);
        delayed.restart();
    }

    property Process statusProc: Process {
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

    property Timer pollTimer: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    property Timer delayed: Timer {
        interval: 1200
        onTriggered: root.refresh()
    }
}
