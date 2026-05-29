import QtQuick
import Quickshell
import Quickshell.Io

// Network pill. NetworkManager has no stable native Quickshell service yet, so
// we shell out to nmcli and parse the JSON it emits. The script is inlined via
// `bash -c` (no external file/path to resolve through symlinks). Wifi shows a
// signal-strength ramp; ethernet shows a link glyph.
Pill {
    id: root

    property var info: ({
            type: "disconnected"
        })

    readonly property var wifiIcons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

    function wifiIcon(strength) {
        let i = Math.min(4, Math.floor((strength / 100) * 5));
        return wifiIcons[Math.max(0, i)];
    }

    // Emits one JSON line describing the primary connection.
    readonly property string script: [
        "line=$(nmcli -t -f TYPE,STATE,DEVICE,CONNECTION device status 2>/dev/null | awk -F: '$2==\"connected\" && $1!=\"loopback\"{print; exit}')",
        "type=$(printf '%s' \"$line\" | cut -d: -f1)",
        "dev=$(printf '%s' \"$line\" | cut -d: -f3)",
        "conn=$(printf '%s' \"$line\" | cut -d: -f4-)",
        "ip=$(nmcli -t -f IP4.ADDRESS device show \"$dev\" 2>/dev/null | head -n1 | cut -d: -f2 | cut -d/ -f1)",
        "if [ \"$type\" = wifi ]; then",
        "  info=$(nmcli -t -f IN-USE,SIGNAL,SSID device wifi 2>/dev/null | awk -F: '$1==\"*\"{print; exit}')",
        "  sig=$(printf '%s' \"$info\" | cut -d: -f2)",
        "  ssid=$(printf '%s' \"$info\" | cut -d: -f3-)",
        "  printf '{\"type\":\"wifi\",\"signal\":%s,\"ssid\":\"%s\",\"ip\":\"%s\"}\\n' \"${sig:-0}\" \"$ssid\" \"$ip\"",
        "elif [ -n \"$type\" ]; then",
        "  printf '{\"type\":\"ethernet\",\"name\":\"%s\",\"ip\":\"%s\"}\\n' \"$conn\" \"$ip\"",
        "else",
        "  printf '{\"type\":\"disconnected\"}\\n'",
        "fi"
    ].join("\n")

    Process {
        id: proc
        command: ["bash", "-c", root.script]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.info = JSON.parse(this.text.trim());
                } catch (e) {
                    root.info = {
                        type: "disconnected"
                    };
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    IconText {
        text: {
            if (root.info.type === "wifi")
                return root.wifiIcon(root.info.signal);
            if (root.info.type === "ethernet")
                return "󰈀";
            return "󰌙";
        }
        color: root.info.type === "disconnected" ? Theme.base03 : Theme.fg
    }

    onClicked: Quickshell.execDetached(["nm-connection-editor"])

    Tooltip {
        anchorItem: root
        shown: root.hovered
        text: {
            if (root.info.type === "wifi")
                return root.info.ssid + "\n" + root.info.signal + "%  ·  " + root.info.ip;
            if (root.info.type === "ethernet")
                return root.info.name + "\n" + root.info.ip;
            return "Disconnected";
        }
    }
}
