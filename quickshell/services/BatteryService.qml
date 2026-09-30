import QtQuick
import Quickshell
import Quickshell.Services.UPower

Scope {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool onBattery: UPower.onBattery
    readonly property bool charging: device && device.state === UPowerDeviceState.Charging
    readonly property bool full: device && (device.state === UPowerDeviceState.FullyCharged || device.percentage >= 1)
    readonly property int percent: device ? Math.round(device.percentage * 100) : -1
    readonly property bool batteryReady: !!device && device.ready && device.isPresent
    readonly property bool discharging: batteryReady && (device.state === UPowerDeviceState.Discharging
        || device.state === UPowerDeviceState.Empty || device.state === UPowerDeviceState.PendingDischarge)

    // Low-battery warnings: one critical toast at 10% and another at 5%, re-armed
    // once the level climbs back above the threshold or the charger is plugged in.
    property bool warnedLow: false
    property bool warnedCritical: false

    function checkLevel(): void {
        if (!root.discharging || !root.onBattery || root.percent < 0) {
            root.warnedLow = false;
            root.warnedCritical = false;
            return;
        }
        if (root.percent > 12)
            root.warnedLow = false;
        if (root.percent > 7)
            root.warnedCritical = false;

        if (root.percent <= 5 && !root.warnedCritical) {
            root.warnedCritical = true;
            root.warnedLow = true;
            root.warnLow();
        } else if (root.percent <= 10 && !root.warnedLow) {
            root.warnedLow = true;
            root.warnLow();
        }
    }

    function warnLow(): void {
        Quickshell.execDetached(["notify-send", "-a", "Battery", "-i", "battery-caution", "-u", "critical", "-t", "30000", "Time to recharge!", "Battery is down to " + root.percent + "%"]);
    }

    onPercentChanged: root.checkLevel()
    onOnBatteryChanged: root.checkLevel()
    onDischargingChanged: root.checkLevel()
}
