import QtQuick
import Quickshell

// A popup that drops down below a bar item. Set `anchorItem` to the widget it
// belongs to and drive `shown` (e.g. from the pill's `hovered`). Put rich
// content as children, or set `text` for a simple label.
//
// It stays open while the cursor is over the popup itself (`contentHovered`)
// and uses a short hide delay so moving from the pill into the popup doesn't
// close it mid-transit.
//
// NB: a PopupWindow is a real Wayland window — it needs an explicit, non-zero
// `width`/`height` and a valid (>=1x1) anchor rect or the compositor rejects
// the surface and Quickshell crashes. The frame/timer go through the explicit
// `data:` list so they are not swallowed by the `content` default alias.
PopupWindow {
    id: root

    property Item anchorItem
    property bool shown: false
    property string text: ""
    default property alias content: body.data

    readonly property bool contentHovered: frameHover.hovered
    readonly property bool wantShown: (shown || contentHovered) && anchorItem !== null

    // Anchor the whole item rect, attach to its bottom edge, grow downward.
    anchor.item: anchorItem
    anchor.rect.x: 0
    anchor.rect.y: 0
    anchor.rect.width: anchorItem ? anchorItem.width : 1
    anchor.rect.height: anchorItem ? anchorItem.height + Theme.gap : 1
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight
    width: frame.implicitWidth
    height: frame.implicitHeight
    color: "transparent"
    visible: false

    onWantShownChanged: {
        if (wantShown) {
            hideTimer.stop();
            visible = true;
        } else {
            hideTimer.restart();
        }
    }

    data: [
        Timer {
            id: hideTimer
            interval: 180
            onTriggered: root.visible = false
        },
        Rectangle {
            id: frame
            anchors.fill: parent
            implicitWidth: Math.max(body.implicitWidth, label.visible ? label.implicitWidth : 0) + 20
            implicitHeight: (label.visible ? label.implicitHeight : body.implicitHeight) + 16
            color: Theme.base00
            radius: Theme.radius

            HoverHandler {
                id: frameHover
            }

            Label {
                id: label
                anchors.centerIn: parent
                visible: root.text.length > 0
                text: root.text
                color: Theme.fgBright
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                id: body
                anchors.centerIn: parent
                implicitWidth: childrenRect.width
                implicitHeight: childrenRect.height
            }
        }
    ]
}
