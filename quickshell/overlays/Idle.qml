import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import ".."

// All monitors pause while IdleState.stayAwake is set
// (SUPER+CTRL+I, or `qs ipc call idle toggle`).
Scope {
    id: root

    property var osd: null

    function toggle(): void {
        IdleState.toggle();
        if (!root.osd)
            return;
        if (IdleState.stayAwake)
            root.osd.showMessage("stay-awake", "Staying awake");
        else
            root.osd.showMessage("idle", "Idle lock enabled");
    }

    IdleMonitor {
        enabled: !IdleState.stayAwake
        timeout: 600
        onIsIdleChanged: Quickshell.execDetached(["hyprctl", "dispatch", isIdle ? "hl.dsp.dpms(\"off\")" : "hl.dsp.dpms(\"on\")"])
    }

    IdleMonitor {
        enabled: !IdleState.stayAwake
        timeout: 630
        onIsIdleChanged: if (isIdle) Quickshell.execDetached(["qs", "ipc", "call", "lock", "lock"])
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "idle-toggle"
        description: "Toggle stay awake"
        onPressed: root.toggle()
    }

    IpcHandler {
        target: "idle"

        function toggle(): bool { root.toggle(); return IdleState.stayAwake; }
        function stayAwake(enabled: bool): void { IdleState.setStayAwake(enabled); }
        function status(): string { return JSON.stringify({ stayAwake: IdleState.stayAwake }); }
    }
}
