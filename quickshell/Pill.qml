import QtQuick

// A rounded module "pill" matching waybar's #module styling.
// Glyph/text children placed inside a `Pill { ... }` flow into a centred Row.
// Exposes `hovered` and forwards clicks/scroll via signals.
//
// Note: Pill's own internals (Row, MouseArea) are assigned through the explicit
// `data:` list so they are NOT swallowed by the `content` default-property
// alias — only the consumer's children land in the Row.
Rectangle {
    id: root

    default property alias content: row.data
    property alias spacing: row.spacing
    readonly property bool hovered: area.containsMouse

    signal clicked(var event)
    signal rightClicked(var event)
    signal middleClicked(var event)
    signal wheel(real delta)

    implicitWidth: Math.max(Theme.pillMinWidth, row.implicitWidth + Theme.hPad * 2)
    implicitHeight: Theme.pillHeight
    color: "transparent"

    data: [
        Row {
            id: row
            anchors.centerIn: root
            spacing: Theme.gap
        },
        MouseArea {
            id: area
            anchors.fill: root
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: function (mouse) {
                if (mouse.button === Qt.LeftButton)
                    root.clicked(mouse);
                else if (mouse.button === Qt.RightButton)
                    root.rightClicked(mouse);
                else if (mouse.button === Qt.MiddleButton)
                    root.middleClicked(mouse);
            }
            onWheel: function (wheel) {
                root.wheel(wheel.angleDelta.y);
            }
        }
    ]
}
