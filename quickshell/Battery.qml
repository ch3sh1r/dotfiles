import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Battery pill backed by UPower (event-driven, no 30s polling). Charge ramp,
// charging ramp, warning/critical colours, and a tooltip with draw + time.
// Click toggles a remaining-time readout. Hidden when there is no battery.
Pill {
    id: root

    // displayDevice is UPower's own synthetic aggregate of the system battery
    // and is the reliable, always-ready source for percentage/rate/time. Raw
    // per-battery entries in UPower.devices can lag (reporting ~1% / a bogus
    // changeRate) until their stats are fetched, so read everything from the
    // aggregate. Its isLaptopBattery flag is often false, so detect battery
    // *presence* by scanning the device list instead.
    readonly property var dev: UPower.displayDevice
    readonly property bool hasBattery: {
        let model = UPower.devices;
        if (model) {
            let list = model.values;
            for (let i = 0; i < list.length; i++)
                if (list[i].isLaptopBattery)
                    return true;
        }
        return dev && (dev.isLaptopBattery || dev.isPresent);
    }
    readonly property bool present: hasBattery && dev && dev.ready
    readonly property int percent: dev ? Math.round(dev.percentage) : 0
    readonly property bool charging: dev && dev.state === UPowerDeviceState.Charging
    readonly property bool full: dev && (dev.state === UPowerDeviceState.FullyCharged || percent >= 100)
    readonly property real watts: dev && dev.changeRate !== undefined ? dev.changeRate : 0

    property bool showTime: false

    visible: present

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
        if (percent <= 10)
            return Theme.critical;
        if (percent <= 20)
            return Theme.warning;
        return Theme.fg;
    }

    Label {
        visible: root.showTime
        text: {
            if (!root.dev)
                return "";
            let t = root.charging ? root.fmtTime(root.dev.timeToFull) : root.fmtTime(root.dev.timeToEmpty);
            return t.length ? t : root.percent + "%";
        }
        color: root.stateColor
    }

    IconText {
        text: {
            if (root.full)
                return "󰂅";
            let i = Math.max(0, Math.min(9, Math.floor(root.percent / 10)));
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
            return Math.round(root.watts) + "W" + arrow + "  " + root.percent + "%";
        }
    }
}
