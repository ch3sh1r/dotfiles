pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Stay-awake flag shared by the Idle overlay (which disables its monitors
// while set) and the bar pill. Persisted so a shell restart keeps it.
Singleton {
    id: root

    property bool stayAwake: false

    function setStayAwake(enabled: bool): void {
        if (root.stayAwake === enabled)
            return;
        root.stayAwake = enabled;
        stateFile.setText(JSON.stringify({ stayAwake: enabled }) + "\n");
    }

    function toggle(): void {
        root.setStayAwake(!root.stayAwake);
    }

    FileView {
        id: stateFile
        path: Quickshell.statePath("idle.json")
        blockLoading: true
        printErrors: false
        onLoaded: {
            try {
                root.stayAwake = JSON.parse(text() || "{}").stayAwake === true;
            } catch (e) {
                root.stayAwake = false;
            }
        }
    }
}
