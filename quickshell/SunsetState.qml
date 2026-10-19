pragma Singleton

import QtQuick

// Shared by SunsetService (schedule) and the bar toggle. Its update()
// recomputes it every minute, so nothing here needs to survive a reload.
QtObject {
    property bool night: false
    property bool scheduledNight: false
    property bool togglePinned: false
    // Half strength preserves the original sunset tint; 0 is neutral.
    property real intensity: 0.5

    function setIntensity(value: real): void {
        if (!isFinite(value))
            return;
        intensity = Math.max(0, Math.min(1, value));
    }

    function toggle(): void {
        togglePinned = true;
        night = !night;
    }
}
