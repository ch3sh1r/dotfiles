import QtQuick
import Quickshell
import Quickshell.Io

// Mullvad VPN pill. Parses `mullvad status --json` natively (no helper script).
// Left-click toggles the connection; right-click opens an in-shell location
// picker — the Quickshell replacement for the old rofi menu.
Pill {
    id: root

    readonly property var favorites: ["de berlin", "se", "us nyc", "fr", "nl", "gb", "jp"]
    readonly property var countries: ["al", "au", "at", "be", "br", "bg", "ca", "cz", "dk", "fi", "fr", "de", "gr", "hk", "hu", "ie", "il", "it", "jp", "lv", "lu", "md", "nl", "nz", "no", "pl", "ro", "rs", "sg", "es", "se", "ch", "gb", "ae", "us"]

    property bool connected: false
    property string city: ""
    property string country: ""
    property string ip: ""

    readonly property var entries: {
        let out = [];
        for (const f of favorites)
            out.push({
                label: "⭐ " + f,
                code: f
            });
        for (const c of countries)
            out.push({
                label: "🌍 " + c,
                code: c
            });
        return out;
    }

    function refresh() {
        statusProc.running = true;
    }

    function setLocation(code) {
        let args = ["mullvad", "relay", "set", "location"].concat(code.split(" "));
        Quickshell.execDetached(args);
        Quickshell.execDetached(["mullvad", "connect"]);
        picker.shown = false;
        delayed.restart();
    }

    Process {
        id: statusProc
        command: ["mullvad", "status", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let s = JSON.parse(this.text.trim());
                    root.connected = s.state === "connected";
                    let loc = (s.details && s.details.location) || {};
                    root.city = loc.city || "";
                    root.country = loc.country || "";
                    root.ip = loc.ipv4 || "";
                } catch (e) {
                    root.connected = false;
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statusProc.running = true
    }

    // Re-poll quickly right after a toggle/connect.
    Timer {
        id: delayed
        interval: 1200
        repeat: false
        onTriggered: root.refresh()
    }

    IconText {
        text: root.connected ? "󰊠" : "󰧵"
        color: root.connected ? Theme.good : Theme.base03
    }

    Label {
        visible: root.connected && root.city.length > 0
        text: root.city
        color: Theme.fgBright
    }

    onClicked: {
        Quickshell.execDetached(["mullvad", root.connected ? "disconnect" : "connect"]);
        delayed.restart();
    }
    onRightClicked: picker.shown = !picker.shown

    Tooltip {
        anchorItem: root
        shown: root.hovered && !picker.shown
        text: root.connected ? (root.city + ", " + root.country + "\n" + root.ip) : "Mullvad is not connected"
    }

    // Location picker popup.
    PopupWindow {
        id: picker
        property bool shown: false
        visible: shown

        anchor.item: root
        anchor.rect.x: (root.width - width) / 2
        anchor.rect.y: root.height + Theme.gap

        implicitWidth: 200
        implicitHeight: 320
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Theme.base00
            radius: Theme.radius

            Column {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 4

                Label {
                    text: "Mullvad location"
                    color: Theme.purple
                    font.bold: true
                }

                ListView {
                    width: parent.width
                    height: parent.height - 24
                    clip: true
                    model: root.entries
                    spacing: 1

                    delegate: Rectangle {
                        required property var modelData
                        width: ListView.view.width
                        height: 22
                        radius: Theme.radius
                        color: hov.hovered ? Theme.pillBg : "transparent"

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 6
                            text: parent.modelData.label
                            color: Theme.fgBright
                        }

                        HoverHandler {
                            id: hov
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.setLocation(parent.modelData.code)
                        }
                    }
                }
            }
        }
    }
}
