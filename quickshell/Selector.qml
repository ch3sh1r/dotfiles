import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: root

    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-selector"

    readonly property string dataScript: Qt.resolvedUrl("scripts/selector-data.sh").toString().replace("file://", "")
    readonly property string actionScript: Qt.resolvedUrl("scripts/selector-action.sh").toString().replace("file://", "")

    property string mode: ""
    property string target: ""
    property string title: ""
    property string query: ""
    property string error: ""
    property bool pendingPreviews: false
    property int selected: 0
    property var items: []
    property var matches: []

    function itemText(item) {
        return ((item.title || "") + " " + (item.subtitle || "")).toLowerCase();
    }

    function refresh() {
        let q = root.query.trim().toLowerCase();
        let next = [];

        for (let i = 0; i < root.items.length; i++) {
            let item = root.items[i];
            if (q.length === 0 || root.itemText(item).indexOf(q) !== -1)
                next.push(item);
            if (next.length >= 12)
                break;
        }

        root.matches = next;
        root.selected = Math.max(0, Math.min(root.selected, root.matches.length - 1));
    }

    function open(mode: string, target: string): void {
        root.mode = mode;
        root.target = target;
        root.title = mode === "rbw" ? "Bitwarden " + target : "Clipboard";
        root.query = "";
        root.error = "";
        root.items = [];
        root.matches = [];
        root.selected = 0;
        root.visible = true;
        search.forceActiveFocus();
        dataProc.running = true;
    }

    function close(): void {
        root.visible = false;
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
        if (root.pendingPreviews && root.mode === "clipboard")
            previewRefresh.restart();
    }

    function activate(item) {
        if (!item)
            return;
        actionProc.command = ["bash", root.actionScript, root.mode, root.target, item.id];
        actionProc.running = true;
        root.close();
    }

    function deleteSelected() {
        if (root.mode !== "clipboard" || root.matches.length === 0)
            return;
        let item = root.matches[root.selected];
        actionProc.command = ["bash", root.actionScript, "clipboard", "delete", item.id];
        actionProc.running = true;
        root.items = root.items.filter(i => i.id !== item.id);
        root.refresh();
    }

    onQueryChanged: refresh()

    IpcHandler {
        target: "selector"

        function rbw(target: string): void { root.open("rbw", target); }
        function clipboard(): void { root.open("clipboard", "copy"); }
        function close(): void { root.close(); }
    }

    Process {
        id: dataProc
        command: ["bash", root.dataScript, root.mode]
        stdout: StdioCollector {
            onStreamFinished: root.applyData(this.text)
        }
    }

    Process {
        id: actionProc
    }

    Timer {
        id: previewRefresh
        interval: 700
        repeat: false
        onTriggered: if (root.visible && root.mode === "clipboard") dataProc.running = true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    Rectangle {
        id: frame
        width: Math.min(680, root.width - 32)
        height: Math.min(500, root.height - 72)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 72
        radius: Theme.radius * 2
        color: Theme.base00
        border.width: 1
        border.color: Theme.base02

        MouseArea {
            anchors.fill: parent
            onClicked: mouse => mouse.accepted = true
        }

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            Label {
                width: parent.width
                text: root.title
                color: Theme.purple
                font.bold: true
                font.pixelSize: Theme.menuTitleFontSize
                elide: Text.ElideRight
            }

            Rectangle {
                width: parent.width
                height: 42
                radius: Theme.radius
                color: Theme.base01
                border.width: 1
                border.color: search.activeFocus ? Theme.accent : Theme.base02

                IconText {
                    id: promptIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰍉"
                    color: Theme.base04
                }

                TextInput {
                    id: search
                    anchors.left: promptIcon.right
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    anchors.rightMargin: 12
                    clip: true
                    color: Theme.fgBright
                    selectionColor: Theme.accent
                    selectedTextColor: Theme.base00
                    font.family: Theme.font
                    font.pixelSize: Theme.menuInputFontSize
                    text: root.query
                    onTextChanged: root.query = text

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            root.close();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            root.selected = Math.min(root.selected + 1, root.matches.length - 1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            root.selected = Math.max(root.selected - 1, 0);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Delete) {
                            root.deleteSelected();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.activate(root.matches[root.selected]);
                            event.accepted = true;
                        }
                    }
                }

                Label {
                    anchors.left: search.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: search.text.length === 0 && !search.activeFocus
                    text: "Search"
                    color: Theme.base03
                    font.pixelSize: Theme.menuFontSize
                }
            }

            Label {
                width: parent.width
                visible: root.error.length > 0
                text: root.error
                color: Theme.warning
                font.pixelSize: Theme.menuFontSize
                wrapMode: Text.Wrap
            }

            ListView {
                id: results
                width: parent.width
                height: parent.height - y
                clip: true
                spacing: 4
                model: root.matches
                currentIndex: root.selected

                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    readonly property bool hasPreview: (modelData.image || "").length > 0

                    width: results.width
                    height: hasPreview ? 82 : 44
                    radius: Theme.radius
                    color: index === root.selected ? Theme.base02 : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: parent.hasPreview ? 10 : 0

                        IconImage {
                            width: parent.parent.hasPreview ? 64 : 24
                            height: parent.parent.hasPreview ? 64 : 24
                            anchors.verticalCenter: parent.verticalCenter
                            visible: parent.parent.hasPreview || root.mode !== "clipboard"
                            source: parent.parent.hasPreview ? "file://" + modelData.image : Quickshell.iconPath(modelData.icon || "edit-paste", "application-x-executable")
                        }

                        Column {
                            width: parent.width - (parent.parent.hasPreview || root.mode !== "clipboard" ? (parent.parent.hasPreview ? 74 : 34) : 0)
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Label {
                                width: parent.width
                                text: modelData.title
                                color: Theme.fgBright
                                font.pixelSize: Theme.menuFontSize
                                elide: Text.ElideRight
                            }

                            Label {
                                width: parent.width
                                visible: root.mode !== "clipboard" && (modelData.subtitle || "").length > 0
                                text: modelData.subtitle || ""
                                color: Theme.base04
                                font.pixelSize: Theme.menuFontSize
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: root.selected = index
                        onClicked: root.activate(modelData)
                    }
                }
            }
        }
    }
}
