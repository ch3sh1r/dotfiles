import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import ".."

// Full-screen overlay with a search box and a keyboard-driven result list,
// shared by the launcher and the selector. Consumers own the data: they fill
// `matches` (usually through applyMatches()) and handle `activated(item)`.
//
// `describe(item)` maps an item to { title, subtitle, icon, glyph }: `icon` is
// an icon name for Quickshell.iconPath, `glyph` a Nerd Font character used
// when there is no icon. Set `preview` to show a pane next to the list.
PanelWindow {
    id: root

    property string title: ""
    property string placeholder: "Search"
    property string error: ""
    property string query: ""
    property int selected: 0
    property int maxResults: 30
    property int frameWidth: Theme.pickerWidth
    property var matches: []
    property var describe: item => ({
            title: String(item)
        })
    property Component preview: null
    readonly property var selectedItem: selected >= 0 && selected < matches.length ? matches[selected] : null

    signal activated(var item)
    signal deleteRequested(var item)

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

    // Filter `items` by the query (case-insensitive substring of textOf(item)),
    // optionally sort with compare(a, b, query), and keep the selection valid.
    function applyMatches(items, textOf, compare): void {
        let q = root.query.trim().toLowerCase();
        let next = [];

        for (let i = 0; i < items.length; i++) {
            if (q.length === 0 || textOf(items[i]).toLowerCase().indexOf(q) !== -1)
                next.push(items[i]);
        }

        if (compare)
            next.sort((a, b) => compare(a, b, q));

        root.matches = next.slice(0, root.maxResults);
        root.selected = Math.max(0, Math.min(root.selected, root.matches.length - 1));
    }

    function focusedScreen() {
        let focused = Hyprland.focusedMonitor;
        if (!focused)
            return null;

        for (let i = 0; i < Quickshell.screens.length; i++) {
            let screen = Quickshell.screens[i];
            let monitor = Hyprland.monitorFor(screen);
            if (monitor && monitor.name === focused.name)
                return screen;
        }

        return null;
    }

    function show(): void {
        let targetScreen = root.focusedScreen();
        if (targetScreen)
            root.screen = targetScreen;

        root.visible = true;
        search.forceActiveFocus();
    }

    function close(): void {
        root.visible = false;
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    Rectangle {
        id: frame
        width: Math.min(root.frameWidth, root.width - 32)
        height: Math.min(Theme.pickerHeight, root.height - Theme.pickerTopMargin)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Theme.pickerTopMargin
        radius: Theme.radius * 2
        color: Theme.base00
        border.width: 1
        border.color: Theme.base02

        SunsetTint {
            radius: frame.radius
        }

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
                visible: root.title.length > 0
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
                            if (root.selectedItem)
                                root.deleteRequested(root.selectedItem);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.selectedItem)
                                root.activated(root.selectedItem);
                            event.accepted = true;
                        }
                    }
                }

                Label {
                    anchors.left: search.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: search.text.length === 0 && !search.activeFocus
                    text: root.placeholder
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

            Row {
                width: parent.width
                height: parent.height - y
                spacing: 12

                ListView {
                    id: results
                    width: root.preview ? Math.floor((parent.width - parent.spacing) * 0.48) : parent.width
                    height: parent.height
                    clip: true
                    spacing: 4
                    model: root.matches
                    currentIndex: root.selected

                    delegate: Rectangle {
                        id: row
                        required property var modelData
                        required property int index
                        readonly property var info: root.describe(modelData)

                        width: results.width
                        height: 44
                        radius: Theme.radius
                        color: index === root.selected ? Theme.base02 : "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Item {
                                id: leading
                                width: 24
                                height: 24
                                anchors.verticalCenter: parent.verticalCenter

                                IconImage {
                                    anchors.fill: parent
                                    visible: !!row.info.icon
                                    source: row.info.icon ? Quickshell.iconPath(row.info.icon, "application-x-executable") : ""
                                }

                                IconText {
                                    anchors.centerIn: parent
                                    visible: !row.info.icon
                                    text: row.info.glyph || ""
                                    color: Theme.base04
                                }
                            }

                            Column {
                                width: parent.width - leading.width - parent.spacing
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1

                                Label {
                                    width: parent.width
                                    text: row.info.title || ""
                                    color: Theme.fgBright
                                    font.pixelSize: Theme.menuFontSize
                                    elide: Text.ElideRight
                                }

                                Label {
                                    width: parent.width
                                    visible: (row.info.subtitle || "").length > 0
                                    text: row.info.subtitle || ""
                                    color: Theme.base04
                                    font.pixelSize: Theme.menuFontSize
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.selected = row.index
                            onClicked: root.activated(row.modelData)
                        }
                    }
                }

                Loader {
                    width: parent.width - results.width - parent.spacing
                    height: parent.height
                    active: root.preview !== null
                    visible: active
                    sourceComponent: root.preview
                }
            }
        }
    }
}
