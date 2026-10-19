pragma Singleton

import QtQuick

// Coordinates bar popups: pinning a new popup asks the others to unpin.
QtObject {
    signal dismissRequested()

    function dismiss(): void {
        dismissRequested();
    }
}
