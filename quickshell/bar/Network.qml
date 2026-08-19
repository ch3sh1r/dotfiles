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
    tooltip: {
        if (root.info.type === "wifi")
            return (root.info.ssid.length > 0 ? root.info.ssid : "Wi-Fi") + "\n" + root.info.signal + "%  ·  " + root.info.ip;
        if (root.info.type === "ethernet")
            return root.info.name + "\n" + root.info.ip;
        return "Disconnected";
    }

    required property var backend
    property bool compact: false
    readonly property var info: backend.info
    readonly property var wifiIcons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

    function wifiIcon(strength) {
        let i = Math.min(4, Math.floor((strength / 100) * 5));
        return wifiIcons[Math.max(0, i)];
    }

}
