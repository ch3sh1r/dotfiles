import QtQuick
import Quickshell.Services.UPower

QtObject {
    readonly property var device: UPower.displayDevice
    readonly property bool onBattery: UPower.onBattery
    readonly property bool charging: device && device.state === UPowerDeviceState.Charging
    readonly property bool full: device && (device.state === UPowerDeviceState.FullyCharged || device.percentage >= 1)
}
