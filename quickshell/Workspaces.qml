import QtQuick
import Quickshell
import Quickshell.Hyprland

// Live workspace strip. Unlike the waybar module this reacts to Hyprland's IPC
// socket directly (no polling) and renders one button per existing workspace
// on this monitor. Click activates; scroll cycles.
Item {
    id: root

    property string monitorName: ""

    implicitWidth: row.implicitWidth
    implicitHeight: Theme.pillHeight

    // Existing workspaces on this monitor, sorted by id.
    readonly property var list: {
        let arr = Hyprland.workspaces.values.filter(function (ws) {
            return root.monitorName === "" || (ws.monitor && ws.monitor.name === root.monitorName);
        });
        arr.sort(function (a, b) {
            return a.id - b.id;
        });
        return arr;
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Repeater {
            model: root.list

            delegate: Rectangle {
                id: btn
                required property var modelData

                readonly property bool isActive: modelData.active
                readonly property bool isUrgent: modelData.urgent

                implicitWidth: Math.max(Theme.pillHeight, lbl.implicitWidth + Theme.hPad * 2)
                implicitHeight: Theme.pillHeight
                radius: Theme.radius
                // Outline only for the current desktop; others stay flat.
                color: !isActive && hover.hovered ? Theme.pillBg : "transparent"
                border.width: isActive ? 1 : 0
                border.color: Theme.accent

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Label {
                    id: lbl
                    anchors.centerIn: parent
                    text: btn.modelData.name
                    color: btn.isUrgent ? Theme.urgent : (btn.isActive ? Theme.accent : Theme.fgBright)
                    font.bold: btn.isActive || btn.isUrgent
                }

                HoverHandler {
                    id: hover
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + btn.modelData.id)
                }
            }
        }
    }

    // Scroll anywhere over the strip to cycle workspaces.
    WheelHandler {
        onWheel: function (event) {
            Hyprland.dispatch(event.angleDelta.y > 0 ? "workspace e-1" : "workspace e+1");
        }
    }
}
