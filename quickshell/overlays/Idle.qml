import QtQuick
import Quickshell
import Quickshell.Wayland

// Detached so a still-running command (the suspend check sleeps) never
// swallows the next one.
Scope {
    IdleMonitor {
        timeout: 600
        onIsIdleChanged: Quickshell.execDetached(["hyprctl", "dispatch", isIdle ? "hl.dsp.dpms(\"off\")" : "hl.dsp.dpms(\"on\")"])
    }

    IdleMonitor {
        timeout: 630
        onIsIdleChanged: if (isIdle) Quickshell.execDetached(["qs", "ipc", "call", "lock", "lock"])
    }

    IdleMonitor {
        timeout: 3600
        onIsIdleChanged: if (isIdle) Quickshell.execDetached(["sh", "-c", "qs ipc call lock lock && sleep 2 && [ \"$(qs ipc call lock isLocked)\" = true ] && systemctl suspend"])
    }
}
