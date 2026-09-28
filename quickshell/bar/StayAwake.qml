import QtQuick
import ".."
import "../components"

// Manual-state indicator: only shown while stay-awake is on. Toggle it with
// SUPER+CTRL+I; clicking the pill turns it back off.
StatusPill {
    id: root

    visible: IdleState.stayAwake
    icon: "󰅶"
    iconColor: Theme.warning
    tooltip: "Staying awake. Click to allow idle lock"

    onClicked: IdleState.setStayAwake(false)
}
