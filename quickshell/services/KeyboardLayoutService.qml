import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Tracks the active keyboard layout for the lock UI. A device query seeds it
// on lock/recovery; Hyprland events keep it current while the shell is alive.
Scope {
    id: root

    property string layout: ""
    readonly property string shortLayout: root.abbreviatedLayout()

    function refresh(): void {
        layoutProc.running = true;
    }

    function updateLayout(text): void {
        try {
            let devices = JSON.parse(text.trim() || "{}");
            let keyboards = devices.keyboards || [];
            let fallback = "";

            for (let i = 0; i < keyboards.length; i++) {
                let layout = keyboards[i].active_keymap || "";
                if (layout.length === 0)
                    continue;

                if (fallback.length === 0)
                    fallback = layout;

                if (keyboards[i].main) {
                    root.layout = layout;
                    return;
                }
            }

            root.layout = fallback;
        } catch (e) {
            root.layout = "";
        }
    }

    function updateFromEvent(event): void {
        if (event.name !== "activelayout")
            return;

        let args = event.parse(2);
        if (args.length >= 2 && args[1].length > 0)
            root.layout = args[1];
    }

    function abbreviatedLayout(): string {
        let layout = root.layout.toLowerCase();

        if (layout.indexOf("russian") !== -1 || layout.indexOf("ru") === 0)
            return "RU";
        if (layout.indexOf("english") !== -1 || layout.indexOf("us") !== -1)
            return "EN";

        return root.layout.length >= 2 ? root.layout.slice(0, 2).toUpperCase() : "--";
    }

    Connections {
        target: Hyprland

        function onRawEvent(event): void {
            root.updateFromEvent(event);
        }
    }

    Process {
        id: layoutProc
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.updateLayout(this.text)
        }
    }
}
