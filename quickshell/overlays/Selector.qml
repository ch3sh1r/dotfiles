import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import ".."
import "../components"

PickerWindow {
    id: root

    WlrLayershell.namespace: "quickshell-selector"

    readonly property string dataScript: Theme.scriptPath("selector-data.sh")
    readonly property string actionScript: Theme.scriptPath("selector-action.sh")

    property string mode: ""
    property string target: ""
    property bool pendingPreviews: false
    property bool showAfterData: false
    property var rbwItem: null
    property var items: []
    property var queuedArgs: null

    maxResults: 12
    frameWidth: root.mode === "clipboard" ? Theme.pickerWideWidth : Theme.pickerWidth
    preview: root.mode === "clipboard" ? clipboardPreview : null
    describe: item => ({
            title: item.title || "",
            subtitle: root.mode === "clipboard" ? "" : (item.subtitle || ""),
            glyph: (item.image || "").length > 0 ? "󰋩" : "󰅇"
        })

    function itemText(item) {
        return (item.title || "") + " " + (item.subtitle || "");
    }

    function refresh() {
        let byLastUse = null;
        if (root.mode === "rbw" && root.target === "menu") {
            byLastUse = (a, b) => {
                let ac = rbwUsage.values[a.id] || 0;
                let bc = rbwUsage.values[b.id] || 0;
                if (bc !== ac)
                    return bc - ac;
                return (a.title || "").localeCompare(b.title || "");
            };
        }
        root.applyMatches(root.items, root.itemText, byLastUse);
    }

    // One data run at a time. A request made while a run (e.g. a preview
    // refresh or another mode) is still going is queued, and the output of the
    // superseded run is dropped instead of landing in the new mode.
    function loadData(args): void {
        if (dataProc.running) {
            root.queuedArgs = args;
            return;
        }
        dataProc.command = ["bash", root.dataScript].concat(args);
        dataProc.running = true;
    }

    function runQueued(): void {
        if (root.queuedArgs === null)
            return;
        let args = root.queuedArgs;
        root.queuedArgs = null;
        root.loadData(args);
    }

    function open(mode: string, target: string): void {
        root.mode = mode;
        root.target = mode === "rbw" && target.length === 0 ? "menu" : target;
        root.title = mode === "rbw" ? "Bitwarden" : "Clipboard";
        root.query = "";
        root.error = "";
        root.rbwItem = null;
        root.items = [];
        root.matches = [];
        root.selected = 0;
        // rbw may prompt for the vault password first; only show once data is in.
        root.showAfterData = root.mode === "rbw";
        if (!root.showAfterData)
            root.show();
        root.loadData([root.mode]);
    }

    // Also cancels a pending rbw open that has not shown the window yet.
    function hide(): void {
        root.showAfterData = false;
        root.queuedArgs = null;
        previewRefresh.stop();
        root.close();
    }

    function applyData(text) {
        try {
            let data = JSON.parse(text.trim() || "{}");
            root.error = data.error || "";
            root.pendingPreviews = data.pendingPreviews || false;
            root.items = data.items || [];
        } catch (e) {
            root.error = "Could not parse selector data";
            root.pendingPreviews = false;
            root.items = [];
        }
        root.refresh();
        if (root.showAfterData) {
            root.showAfterData = false;
            root.show();
        }
        if (root.pendingPreviews && root.mode === "clipboard")
            previewRefresh.restart();
    }

    function runAction(args): void {
        Quickshell.execDetached(["bash", root.actionScript].concat(args));
    }

    onQueryChanged: refresh()
    onVisibleChanged: {
        if (!visible) {
            root.showAfterData = false;
            previewRefresh.stop();
        }
    }

    onActivated: item => {
        if (root.mode === "rbw" && root.target === "menu") {
            root.rbwItem = item;
            root.target = "action";
            root.title = "Bitwarden " + item.title;
            root.query = "";
            root.selected = 0;
            root.items = [];
            root.matches = [];
            root.close();
            root.showAfterData = true;
            root.loadData(["rbw-actions", item.id]);
            return;
        }

        if (root.mode === "rbw" && root.target === "action") {
            rbwUsage.set(root.rbwItem.id, Date.now());
            root.runAction(["rbw", item.id, root.rbwItem.id]);
            root.close();
            return;
        }

        root.runAction([root.mode, root.target, item.id]);
        root.close();
    }

    onDeleteRequested: item => {
        if (root.mode !== "clipboard")
            return;
        root.runAction(["clipboard", "delete", item.id]);
        root.items = root.items.filter(i => i.id !== item.id);
        root.refresh();
    }

    JsonStore {
        id: rbwUsage
        fileName: "selector-rbw-usage.json"
        onValuesChanged: root.refresh()
    }

    IpcHandler {
        target: "selector"

        function rbw(target: string): void { root.open("rbw", target); }
        function clipboard(): void { root.open("clipboard", "copy"); }
        function close(): void { root.hide(); }
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "clipboard"
        description: "Clipboard history"
        onPressed: root.open("clipboard", "copy")
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "rbw"
        description: "Bitwarden picker"
        onPressed: root.open("rbw", "menu")
    }

    Process {
        id: dataProc
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.queuedArgs === null)
                    root.applyData(this.text);
            }
        }
        // Deferred so the finished run's stdout is handled (and dropped) first.
        onExited: Qt.callLater(root.runQueued)
    }

    Timer {
        id: previewRefresh
        interval: 700
        repeat: false
        onTriggered: if (root.visible && root.mode === "clipboard") root.loadData(["clipboard"])
    }

    Component {
        id: clipboardPreview

        Rectangle {
            id: preview
            radius: Theme.radius
            color: Theme.base01
            border.width: 1
            border.color: Theme.base02
            clip: true

            readonly property var item: root.selectedItem
            readonly property bool hasImage: !!item && (item.image || "").length > 0

            IconImage {
                anchors.fill: parent
                anchors.margins: 14
                visible: preview.hasImage
                source: preview.hasImage ? "file://" + preview.item.image : ""
                mipmap: true
            }

            Flickable {
                anchors.fill: parent
                anchors.margins: 14
                visible: !preview.hasImage
                contentWidth: width
                contentHeight: previewText.implicitHeight
                clip: true

                Label {
                    id: previewText
                    width: parent.width
                    text: preview.item ? preview.item.title : ""
                    color: Theme.fgBright
                    font.pixelSize: Theme.menuFontSize
                    wrapMode: Text.Wrap
                }
            }

            Label {
                anchors.centerIn: parent
                visible: !preview.item
                text: "No selection"
                color: Theme.base03
                font.pixelSize: Theme.menuFontSize
            }
        }
    }
}
