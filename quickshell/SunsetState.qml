pragma Singleton

import QtQuick

// Shared by the Sunset overlay (schedule) and the bar toggle. Sunset.update()
// recomputes it every minute, so nothing here needs to survive a reload.
QtObject {
    property bool night: false
    property bool scheduledNight: false
    property bool togglePinned: false
}
