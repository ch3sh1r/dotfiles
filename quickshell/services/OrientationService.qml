import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    readonly property string targetMonitor: "DSI-1"
    readonly property string scriptPath: Qt.resolvedUrl("../scripts/orientation-lock.sh").toString().replace("file://", "")
    readonly property bool available: {
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === root.targetMonitor)
                return true;
        }
        return false;
    }

    property bool locked: false
    property string currentTransform: ""

    function refresh(): void {
        statusProc.running = true;
    }

    function applyStatus(text: string): void {
        try {
            let status = JSON.parse(text.trim());
            root.locked = status.locked;
            root.currentTransform = status.transform || "";
        } catch (e) {
            root.locked = false;
            root.currentTransform = "";
        }
    }

    function toggle(): void {
        toggleProc.running = true;
        delayed.restart();
    }

    Process {
        id: statusProc
        command: ["bash", root.scriptPath, "status", root.targetMonitor]
        stdout: StdioCollector {
            onStreamFinished: root.applyStatus(this.text)
        }
    }

    Process {
        id: toggleProc
        command: ["bash", root.scriptPath, "toggle", root.targetMonitor]
        stdout: StdioCollector {
            onStreamFinished: root.applyStatus(this.text)
        }
    }

    Timer {
        interval: 3000
        running: root.available
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Timer {
        id: delayed
        interval: 700
        onTriggered: root.refresh()
    }
}
