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
    WlrLayershell.namespace: "quickshell-launcher"

    property string query: ""
    property int selected: 0
    property var matches: []
    property var usageCounts: ({})

    FileView {
        id: usageFile
        path: Quickshell.statePath("launcher-usage.json")
        blockLoading: true
        printErrors: false
        onLoaded: root.loadUsage()
        onFileChanged: reload()
    }

    function entryText(entry) {
        return ((entry.name || "") + " " + (entry.genericName || "") + " " + (entry.comment || "") + " " + (entry.keywords || []).join(" ")).toLowerCase();
    }

    function refresh() {
        let q = root.query.trim().toLowerCase();
        let all = DesktopEntries.applications.values;
        let next = [];

        for (let i = 0; i < all.length; i++) {
            let entry = all[i];
            if (q.length === 0 || root.entryText(entry).indexOf(q) !== -1)
                next.push(entry);
        }

        next.sort((a, b) => {
            let ac = root.usageCounts[a.id] || 0;
            let bc = root.usageCounts[b.id] || 0;
            if (bc !== ac)
                return bc - ac;
            return (a.name || "").localeCompare(b.name || "");
        });

        if (next.length > 12)
            next = next.slice(0, 12);

        root.matches = next;
        root.selected = Math.max(0, Math.min(root.selected, root.matches.length - 1));
    }

    function loadUsage() {
        try {
            root.usageCounts = JSON.parse(usageFile.text() || "{}");
        } catch (e) {
            root.usageCounts = {};
        }
        root.refresh();
    }

    function recordLaunch(entry) {
        let next = Object.assign({}, root.usageCounts);
        next[entry.id] = (next[entry.id] || 0) + 1;
        root.usageCounts = next;
        usageFile.setText(JSON.stringify(next, null, 2) + "\n");
    }

    function open(): void {
        root.query = "";
        root.selected = 0;
        root.refresh();
        root.visible = true;
        search.forceActiveFocus();
    }

    function close(): void {
        root.visible = false;
    }

    function toggle(): void {
        if (root.visible)
            root.close();
        else
            root.open();
    }

    function launch(entry) {
        if (!entry)
            return;
        root.recordLaunch(entry);
        root.close();
        entry.execute();
    }

    onQueryChanged: refresh()

    IpcHandler {
        target: "launcher"

        function open(): void { root.open(); }
        function close(): void { root.close(); }
        function toggle(): void { root.toggle(); }
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
                    font.pixelSize: 18
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
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.launch(root.matches[root.selected]);
                            event.accepted = true;
                        }
                    }
                }

                Label {
                    anchors.left: search.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: search.text.length === 0 && !search.activeFocus
                    text: "Search applications"
                    color: Theme.base03
                }
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

                    width: results.width
                    height: 44
                    radius: Theme.radius
                    color: index === root.selected ? Theme.base02 : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        IconImage {
                            width: 24
                            height: 24
                            anchors.verticalCenter: parent.verticalCenter
                            source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                        }

                        Column {
                            width: parent.width - 34
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Label {
                                width: parent.width
                                text: modelData.name
                                color: Theme.fgBright
                                elide: Text.ElideRight
                            }

                            Label {
                                width: parent.width
                                visible: (modelData.genericName || modelData.comment || "").length > 0
                                text: modelData.genericName || modelData.comment || ""
                                color: Theme.base04
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: root.selected = index
                        onClicked: root.launch(modelData)
                    }
                }
            }
        }
    }

    Component.onCompleted: refresh()
}
