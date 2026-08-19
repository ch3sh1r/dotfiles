import Quickshell

Scope {
    readonly property alias mullvad: mullvadService
    readonly property alias tailscale: tailscaleService
    readonly property alias network: networkService
    readonly property alias audio: audioService
    readonly property alias battery: batteryService
    readonly property alias orientation: orientationService
    readonly property alias clock: clockService

    MullvadService { id: mullvadService }
    TailscaleService { id: tailscaleService }
    NetworkService { id: networkService }
    AudioService { id: audioService }
    BatteryService { id: batteryService }
    OrientationService { id: orientationService }
    ClockService { id: clockService }
}
