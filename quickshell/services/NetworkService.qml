import QtQuick
import Quickshell
import ".."
import "../components"

// Polls the daemon-independent helper once for all bars. Failure is presented
// as disconnected instead of retaining a stale link status.
Scope {
    id: root

    property var info: ({
            type: "disconnected"
        })

    JsonPoller {
        command: ["bash", Theme.scriptPath("network.sh")]
        interval: 5000

        onParsed: data => root.info = data
        onFailed: root.info = {
            type: "disconnected"
        }
    }
}
