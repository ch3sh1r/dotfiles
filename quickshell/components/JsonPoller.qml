import QtQuick
import Quickshell
import Quickshell.Io

// Runs `command` every `interval` ms while `active` and emits `parsed(data)`
// with the JSON printed on stdout. Empty or invalid output emits `failed()`,
// so a missing binary or a stopped daemon resets the consumer to defaults.
Scope {
    id: root

    property var command: []
    property int interval: 3000
    property bool active: true

    signal parsed(var data)
    signal failed()

    function refresh(): void {
        proc.running = true;
    }

    // Poll again after `delay` ms, e.g. once a toggle has had time to apply.
    function refreshSoon(delay: int): void {
        delayed.interval = delay;
        delayed.restart();
    }

    Process {
        id: proc
        command: root.command
        stdout: StdioCollector {
            onStreamFinished: {
                let data;
                try {
                    data = JSON.parse(this.text.trim());
                } catch (e) {
                    root.failed();
                    return;
                }
                root.parsed(data);
            }
        }
    }

    Timer {
        interval: root.interval
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Timer {
        id: delayed
        onTriggered: root.refresh()
    }
}
