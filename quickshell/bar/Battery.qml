import QtQuick
import Quickshell.Services.UPower
import ".."
import "../components"

StatusPill {
    id: root

    visible: !!root.dev
    icon: {
        if (!root.dev)
            return "";
        if (root.full)
            return "󰂄";
        let i = Math.max(0, Math.min(9, Math.floor(root.dev.percentage * 10)));
        return root.charging ? root.chargeIcons[i] : root.dischargeIcons[i];
    }
    iconColor: root.stateColor
    tooltip: {
        if (!root.dev)
            return "";
        let arrow = root.charging ? "↑" : "↓";
        return Math.round(root.watts) + "W" + arrow + "  " + root.dev.percentage;
    }

    readonly property var dev: UPower.displayDevice
    readonly property bool charging: dev && dev.state === UPowerDeviceState.Charging
    readonly property bool full: dev && (dev.state === UPowerDeviceState.FullyCharged || dev.percentage >= 1)
    readonly property real watts: dev && dev.changeRate !== undefined ? dev.changeRate : 0

    readonly property var dischargeIcons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    readonly property var chargeIcons: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]

    readonly property color stateColor: {
        if (!dev)
            return Theme.fg;
        if (charging || full)
            return Theme.good;
        if (dev.percentage <= 0.1)
            return Theme.critical;
        if (dev.percentage <= 0.2)
            return Theme.warning;
        return Theme.fg;
    }
}
