import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "../components"

Scope {
    id: root

    readonly property string targetMonitor: Quickshell.env("INTERNAL_MONITOR") || "DSI-1"
    readonly property string scriptPath: Theme.scriptPath("orientation-lock.sh")
    readonly property bool available: {
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === root.targetMonitor)
                return true;
        }
        return false;
    }

    property bool locked: false
    property string currentTransform: ""

    function toggle(): void {
        toggleProc.running = true;
    }

    JsonPoller {
        id: poller
        command: ["bash", root.scriptPath, "status", root.targetMonitor]
        active: root.available

        onParsed: status => {
            root.locked = status.locked === true;
            root.currentTransform = String(status.transform || "");
        }
        onFailed: {
            root.locked = false;
            root.currentTransform = "";
        }
    }

    // The script waits for the rotator to start before it returns.
    Process {
        id: toggleProc
        command: ["bash", root.scriptPath, "toggle", root.targetMonitor]
        onExited: poller.refresh()
    }
}
