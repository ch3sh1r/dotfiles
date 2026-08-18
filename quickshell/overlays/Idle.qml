import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    function run(command): void {
        action.command = command;
        action.running = true;
    }

    IdleMonitor {
        timeout: 600
        onIsIdleChanged: {
            if (isIdle)
                root.run(["hyprctl", "dispatch", "dpms", "off"]);
            else
                root.run(["hyprctl", "dispatch", "dpms", "on"]);
        }
    }

    IdleMonitor {
        timeout: 620
        onIsIdleChanged: if (isIdle) root.run(["qs", "ipc", "call", "lock", "lock"])
    }

    IdleMonitor {
        timeout: 3600
        onIsIdleChanged: if (isIdle) root.run(["sh", "-c", "qs ipc call lock lock && sleep 2 && [ \"$(qs ipc call lock isLocked)\" = true ] && systemctl suspend"])
    }

    Process {
        id: action
    }
}
