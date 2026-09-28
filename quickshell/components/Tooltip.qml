import QtQuick
import Quickshell
import ".."

// A popup that drops down below a bar item. Set `anchorItem` to the widget it
// belongs to and drive `shown` (e.g. from the pill's `hovered`). Put rich
// content as children, or set `text` for a simple label.
//
// It stays open while the cursor is over the popup itself (`contentHovered`)
// and uses a short hide delay so moving from the pill into the popup doesn't
// close it mid-transit.
//
// Click-to-open popups use `pinned`/`togglePinned()`: opening one closes every
// other popup through PopupState. `framed` gives the bordered calendar look.
//
// NB: a PopupWindow is a real Wayland window — it needs an explicit, non-zero
// `width`/`height` and a valid (>=1x1) anchor rect or the compositor rejects
// the surface and Quickshell crashes. The frame/timer go through the explicit
// `data:` list so they are not swallowed by the `content` default alias.
PopupWindow {
    id: root

    property Item anchorItem
    property bool pinned: false
    property bool shown: pinned
    property string text: ""
    property bool framed: false
    property int frameRadius: framed ? Theme.radius * 2 : Theme.radius
    property int frameBorderWidth: framed ? 1 : 0
    property color frameBorderColor: framed ? Theme.base02 : "transparent"
    property bool closeOnClick: false
    default property alias content: body.data
    signal dismissRequested()

    function togglePinned(): void {
        let shouldShow = !root.pinned;
        PopupState.dismiss();
        root.pinned = shouldShow;
    }

    function dismiss() {
        hideTimer.stop();
        root.pinned = false;
        root.visible = false;
        root.dismissRequested();
    }

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
        Connections {
            target: PopupState
            function onDismissRequested() {
                root.pinned = false;
            }
        },
        Timer {
            id: hideTimer
            interval: 180
            onTriggered: root.visible = false
        },
        Rectangle {
            id: frame
            anchors.fill: parent
            implicitWidth: Math.max(body.implicitWidth, label.visible ? label.implicitWidth : 0) + Theme.tooltipPadX * 2
            implicitHeight: (label.visible ? label.implicitHeight : body.implicitHeight) + Theme.tooltipPadY * 2
            color: Theme.base00
            radius: root.frameRadius
            border.width: root.frameBorderWidth
            border.color: root.frameBorderColor

            HoverHandler {
                id: frameHover
            }

            TapHandler {
                enabled: root.closeOnClick
                acceptedButtons: Qt.LeftButton
                onTapped: root.dismiss()
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

            // Popup surfaces render above the fullscreen sunset layer.
            Rectangle {
                anchors.fill: parent
                visible: SunsetState.night
                color: Theme.sunsetTint
            }
        }
    ]
}
