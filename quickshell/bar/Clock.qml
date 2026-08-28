import QtQuick
import ".."
import "../components"
import "../overlays"

Pill {
    id: root

    required property var backend
    property bool pinned: false
    property bool compact: false

    Label {
        text: Qt.formatDateTime(root.backend.date, root.compact ? "HH:mm" : "dddd yyyy-MM-dd HH:mm")
        color: Theme.fgBright
    }

    onClicked: {
        let shouldShow = !root.pinned;
        PopupState.dismiss();
        root.pinned = shouldShow;
    }
    onWheel: function (delta) {
        calendar.shiftYear(delta > 0 ? -1 : 1);
    }

    Tooltip {
        id: cal
        anchorItem: root
        shown: root.pinned
        frameRadius: Theme.radius * 2
        frameBorderWidth: 1
        frameBorderColor: Theme.base02

        Calendar {
            id: calendar
            today: root.backend.date
            birthDate: new Date(1991, 3, 20)
            onClicked: root.pinned = false
        }
    }

    Connections {
        target: PopupState
        function onDismissRequested() {
            root.pinned = false;
        }
    }
}
