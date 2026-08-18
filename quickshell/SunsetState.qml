pragma Singleton

import QtQuick

// Keep this API stable: the state survives configuration reloads.
QtObject {
    property bool night: false
    property bool scheduledNight: false
    property bool togglePinned: false
}
