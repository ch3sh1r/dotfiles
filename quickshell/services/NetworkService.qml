import QtQuick
import Quickshell
import ".."
import "../components"

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
