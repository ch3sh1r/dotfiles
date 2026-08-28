pragma Singleton

import QtQuick

QtObject {
    signal dismissRequested()

    function dismiss(): void {
        dismissRequested();
    }
}
