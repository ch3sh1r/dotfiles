import QtQuick
import Quickshell

// A popup that drops down below a bar item. Set `anchorItem` to the widget it
// belongs to and drive `shown` (e.g. from the pill's `hovered`). Put rich
// content as children, or set `text` for a simple label.
//
// It stays open while the cursor is over the popup itself (`contentHovered`)
// and uses a short hide delay so moving from the pill into the popup doesn't
// close it mid-transit. Quickshell resolves the parent window from anchorItem.
//
// As in Pill, the frame/timer go through the explicit `data:` list so they are
// not swallowed by the `content` default-property alias.
PopupWindow {
    id: root

    property Item anchorItem
    property bool shown: false
    property string text: ""
    default property alias content: body.data

    readonly property bool contentHovered: frameHover.hovered
    readonly property bool wantShown: (shown || contentHovered) && anchorItem !== null

    visible: false

    onWantShownChanged: {
        if (wantShown) {
            hideTimer.stop();
            visible = true;
        } else {
            hideTimer.restart();
        }
    }

    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? (anchorItem.width - width) / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + Theme.gap : 0

    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight
    color: "transparent"

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
            border.color: Theme.base02
            border.width: 1
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
