import QtQuick
import ".."
import "../components"

// Network pill. Reads status straight from the kernel via scripts/network.sh
// (sysfs + /proc/net/wireless + iw/ip), so it works without NetworkManager —
// iwd, wpa_supplicant, systemd-networkd, etc. Wifi shows a signal-strength
// ramp; ethernet shows a link glyph.
StatusPill {
    id: root

    icon: {
        if (root.info.type === "wifi")
            return root.wifiIcon(root.info.signal);
        if (root.info.type === "ethernet")
            return "󰈀";
        return "󰌙";
    }
    iconColor: root.info.type === "disconnected" ? Theme.base03 : Theme.fg
    label: !root.compact && root.info.type === "wifi" && root.info.ssid.length > 0 ? root.info.ssid : ""
    tooltipOnHover: false
    tooltipCloseOnClick: true

    required property var backend
    property bool compact: false
    readonly property var info: backend.info
    readonly property var wifiIcons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

    function wifiIcon(strength) {
        let i = Math.min(4, Math.floor((strength / 100) * 5));
        return wifiIcons[Math.max(0, i)];
    }

    onClicked: root.toggleTooltip()

    tooltipContent: Column {
        spacing: 4

        Row {
            spacing: 6
            IconText {
                text: root.icon
                color: root.iconColor
            }
            Label {
                text: root.info.type === "disconnected" ? "Disconnected" : "Connected"
                color: Theme.fgBright
                font.bold: true
            }
        }

        Label {
            visible: root.info.type !== "disconnected"
            text: root.info.type === "wifi"
                ? "Wi-Fi: " + (root.info.ssid || root.info.name || "unknown")
                : "Ethernet: " + (root.info.name || "unknown")
            color: Theme.fg
        }

        Label {
            visible: root.info.type !== "disconnected" && (root.info.ip || "").length > 0
            text: "Address: " + (root.info.ip || "")
            color: Theme.fg
        }

        Label {
            visible: root.info.type === "wifi"
            text: "Signal: " + (root.info.signal || 0) + "%"
            color: Theme.fg
        }

        Label {
            visible: root.info.type !== "disconnected" && (root.info.gateway || "").length > 0
            text: "Gateway: " + (root.info.gateway || "")
            color: Theme.fg
        }
    }

}
