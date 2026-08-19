import QtQuick
import ".."
import "../components"

StatusPill {
    id: root

    icon: root.locked ? "" : ""
    iconColor: root.locked ? Theme.warning : Theme.fg
    tooltip: (root.locked ? "Orientation locked" : "Auto-rotate enabled")
        + (root.currentTransform.length > 0 ? "\nTransform: " + root.currentTransform : "")

    required property var backend
    property string monitorName: ""
    readonly property string targetMonitor: backend.targetMonitor
    readonly property bool locked: backend.locked
    readonly property string currentTransform: backend.currentTransform

    visible: monitorName === targetMonitor

    onClicked: backend.toggle()
}
