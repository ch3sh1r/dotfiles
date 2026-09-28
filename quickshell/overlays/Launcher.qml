import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../components"

PickerWindow {
    id: root

    WlrLayershell.namespace: "quickshell-launcher"

    placeholder: "Search applications"
    maxResults: 30
    describe: entry => ({
            title: entry.name || "",
            subtitle: entry.genericName || entry.comment || "",
            icon: entry.icon || "application-x-executable"
        })

    function entryText(entry) {
        return (entry.name || "") + " " + (entry.genericName || "") + " " + (entry.comment || "") + " " + (entry.keywords || []).join(" ");
    }

    function matchRank(entry, q) {
        let name = (entry.name || "").toLowerCase();
        if (name === q)
            return 0;
        if (name.indexOf(q) === 0)
            return 1;
        return 2;
    }

    function refresh() {
        root.applyMatches(DesktopEntries.applications.values, root.entryText, (a, b, q) => {
            let ar = root.matchRank(a, q);
            let br = root.matchRank(b, q);
            if (ar !== br)
                return ar - br;
            let ac = usage.values[a.id] || 0;
            let bc = usage.values[b.id] || 0;
            if (bc !== ac)
                return bc - ac;
            return (a.name || "").localeCompare(b.name || "");
        });
    }

    function open(): void {
        root.query = "";
        root.selected = 0;
        root.refresh();
        root.show();
    }

    function toggle(): void {
        if (root.visible)
            root.close();
        else
            root.open();
    }

    onQueryChanged: refresh()
    onActivated: entry => {
        usage.set(entry.id, (usage.values[entry.id] || 0) + 1);
        root.close();
        entry.execute();
    }

    JsonStore {
        id: usage
        fileName: "launcher-usage.json"
    }

    IpcHandler {
        target: "launcher"

        function open(): void { root.open(); }
        function close(): void { root.close(); }
        function toggle(): void { root.toggle(); }
    }
}
