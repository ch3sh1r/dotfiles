import QtQuick
import Quickshell

Pill {
    id: root

    property bool pinned: false

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Label {
        text: Qt.formatDateTime(clock.date, "dddd yyyy-MM-dd HH:mm")
        color: Theme.fgBright
    }

    onClicked: root.pinned = !root.pinned
    onWheel: function (delta) {
        calendar.shiftYear(delta > 0 ? -1 : 1);
    }

    Tooltip {
        id: cal
        anchorItem: root
        shown: root.hovered || root.pinned

        Calendar {
            id: calendar
            today: clock.date
        }
    }
}
