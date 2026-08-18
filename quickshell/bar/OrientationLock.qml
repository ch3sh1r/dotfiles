import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "../components"

StatusPill {
    id: root

    icon: root.locked ? "" : ""
    iconColor: root.locked ? Theme.warning : Theme.fg
    tooltip: (root.locked ? "Orientation locked" : "Auto-rotate enabled")
        + (root.currentTransform.length > 0 ? "\nTransform: " + root.currentTransform : "")

    readonly property string targetMonitor: "DSI-1"
    readonly property string scriptPath: Qt.resolvedUrl("../scripts/orientation-lock.sh").toString().replace("file://", "")

    property string monitorName: ""
    property bool locked: false
    property string currentTransform: ""

    visible: monitorName === targetMonitor

    function refresh() {
        statusProc.running = true;
    }

    function applyStatus(text) {
        try {
            let s = JSON.parse(text.trim());
            root.locked = s.locked;
            root.currentTransform = s.transform || "";
        } catch (e) {
            root.locked = false;
            root.currentTransform = "";
        }
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
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Timer {
        id: delayed
        interval: 700
        repeat: false
        onTriggered: root.refresh()
    }

    onClicked: {
        toggleProc.running = true;
        delayed.restart();
    }
}
