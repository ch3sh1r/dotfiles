import QtQuick
import ".."
import "../components"
import "../overlays"

Pill {
    id: root

    required property var backend
    property bool compact: false

    Label {
        text: Qt.formatDateTime(root.backend.date, root.compact ? "HH:mm" : "dddd yyyy-MM-dd HH:mm")
        color: Theme.fgBright
    }

    onClicked: cal.togglePinned()
    onWheel: function (delta) {
        if (cal.pinned)
            calendar.shiftYear(delta > 0 ? -1 : 1);
    }

    Tooltip {
        id: cal
        anchorItem: root
        framed: true

        Calendar {
            id: calendar
            today: root.backend.date
            onClicked: cal.pinned = false
        }
    }
}
