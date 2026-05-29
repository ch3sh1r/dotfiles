import QtQuick
import Quickshell
import Quickshell.Services.UPower

Pill {
    id: root
    readonly property var dev: UPower.displayDevice
    readonly property bool charging: dev && dev.state === UPowerDeviceState.Charging
    readonly property bool full: dev && (dev.state === UPowerDeviceState.FullyCharged || dev.percentage >= 1)
    readonly property real watts: dev && dev.changeRate !== undefined ? dev.changeRate : 0

    property bool showTime: false

    readonly property var dischargeIcons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    readonly property var chargeIcons: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]

    function fmtTime(seconds) {
        if (!seconds || seconds <= 0)
            return "";
        let h = Math.floor(seconds / 3600);
        let m = Math.floor((seconds % 3600) / 60);
        return h > 0 ? (h + "h " + m + "m") : (m + "m");
    }

    readonly property color stateColor: {
        if (charging || full)
            return Theme.good;
        if (dev.percentage <= 0.1)
            return Theme.critical;
        if (dev.percentage <= 0.2)
            return Theme.warning;
        return Theme.fg;
    }

    IconText {
        text: {
            if (root.full)
                return "󰂄";
            let i = Math.max(0, Math.min(9, Math.floor(root.dev.percentage * 10)));
            return root.charging ? root.chargeIcons[i] : root.dischargeIcons[i];
        }
        color: root.stateColor
    }

    onClicked: root.showTime = !root.showTime

    Tooltip {
        anchorItem: root
        shown: root.hovered
        text: {
            if (!root.dev)
                return "";
            let arrow = root.charging ? "↑" : "↓";
            return Math.round(root.watts) + "W" + arrow + "  " + root.dev.percentage;
        }
    }
}
