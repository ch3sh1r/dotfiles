pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string scriptPath: Qt.resolvedUrl("../scripts/network.sh").toString().replace("file://", "")
    readonly property var wifiIcons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
    property var info: ({
            type: "disconnected"
        })

    function wifiIcon(strength) {
        let i = Math.min(4, Math.floor((strength / 100) * 5));
        return wifiIcons[Math.max(0, i)];
    }

    property Process proc: Process {
        command: ["bash", root.scriptPath]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.info = JSON.parse(this.text.trim());
                } catch (e) {
                    root.info = {
                        type: "disconnected"
                    };
                }
            }
        }
    }

    property Timer timer: Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.proc.running = true
    }
}
