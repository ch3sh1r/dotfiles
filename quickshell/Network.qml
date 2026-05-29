import QtQuick
import Quickshell
import Quickshell.Io

// Network pill. Reads status straight from the kernel via scripts/network.sh
// (sysfs + /proc/net/wireless + iw/ip), so it works without NetworkManager —
// iwd, wpa_supplicant, systemd-networkd, etc. Wifi shows a signal-strength
// ramp; ethernet shows a link glyph.
Pill {
    id: root

    readonly property string scriptPath: Qt.resolvedUrl("scripts/network.sh").toString().replace("file://", "")

    property var info: ({
            type: "disconnected"
        })

    readonly property var wifiIcons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

    function wifiIcon(strength) {
        let i = Math.min(4, Math.floor((strength / 100) * 5));
        return wifiIcons[Math.max(0, i)];
    }

    Process {
        id: proc
        command: ["bash", root.scriptPath]
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

    Label {
        visible: root.info.type === "wifi" && root.info.ssid.length > 0
        text: root.info.type === "wifi" ? root.info.ssid : ""
        color: Theme.fgBright
    }

    Tooltip {
        anchorItem: root
        shown: root.hovered
        text: {
            if (root.info.type === "wifi")
                return (root.info.ssid.length > 0 ? root.info.ssid : "Wi-Fi") + "\n" + root.info.signal + "%  ·  " + root.info.ip;
            if (root.info.type === "ethernet")
                return root.info.name + "\n" + root.info.ip;
            return "Disconnected";
        }
    }
}
