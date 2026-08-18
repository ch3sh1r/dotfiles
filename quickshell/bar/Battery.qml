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
        let percentage = Math.round(root.dev.percentage * 100) + "%";
        if (root.full)
            return percentage + " · Fully charged";

        let pluggedIn = !UPower.onBattery;
        let duration = root.formatDuration(pluggedIn ? root.dev.timeToFull : root.dev.timeToEmpty);
        if (duration.length > 0)
            return percentage + " · " + duration + (pluggedIn ? " until full" : " remaining");
        return percentage + " · " + (pluggedIn ? "On AC power" : "Estimating");
    }

    readonly property var dev: UPower.displayDevice
    readonly property bool charging: dev && dev.state === UPowerDeviceState.Charging
    readonly property bool full: dev && (dev.state === UPowerDeviceState.FullyCharged || dev.percentage >= 1)

    readonly property var dischargeIcons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    readonly property var chargeIcons: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]

    function formatDuration(seconds) {
        if (!seconds || seconds <= 0)
            return "";
        let totalMinutes = Math.max(1, Math.round(seconds / 60));
        let hours = Math.floor(totalMinutes / 60);
        let minutes = totalMinutes % 60;
        if (hours === 0)
            return minutes + "m";
        if (minutes === 0)
            return hours + "h";
        return hours + "h " + minutes + "m";
    }

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
