import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    readonly property string scriptPath: Qt.resolvedUrl("../scripts/network.sh").toString().replace("file://", "")
    property var info: ({
            type: "disconnected"
        })

    function refresh(): void {
        statusProc.running = true;
    }

    Process {
        id: statusProc
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

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
