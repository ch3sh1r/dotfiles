import QtQuick
import Quickshell
import Quickshell.Widgets
import ".."

// Icon, summary and body of a notification. Used by the popups and the
// history list; extra children (e.g. action buttons) go below the body.
Row {
    id: root

    property string image: ""
    property string appIcon: ""
    property string summary: ""
    property string body: ""
    property string timeText: ""
    property color summaryColor: Theme.fgBright
    property int iconSize: 32
    property int bodyLines: 6
    default property alias extra: textColumn.data

    spacing: 8

    IconImage {
        id: icon
        width: root.iconSize
        height: root.iconSize
        visible: source.length > 0
        source: root.image.length > 0
            ? root.image
            : (root.appIcon.length > 0 ? Quickshell.iconPath(root.appIcon) : "")
    }

    Column {
        id: textColumn
        width: root.width - (icon.visible ? icon.width + root.spacing : 0)
        spacing: 4

        Row {
            width: parent.width
            spacing: 8

            Label {
                width: parent.width - (time.visible ? time.width + parent.spacing : 0)
                text: root.summary
                color: root.summaryColor
                font.bold: true
                elide: Text.ElideRight
            }

            Label {
                id: time
                visible: root.timeText.length > 0
                text: root.timeText
                color: Theme.base03
            }
        }

        // StyledText covers the notification markup subset (b, i, u, a, img)
        // and, unlike RichText, honours maximumLineCount and elide.
        Label {
            width: parent.width
            visible: root.body.length > 0
            text: root.body
            color: Theme.fg
            wrapMode: Text.Wrap
            maximumLineCount: root.bodyLines
            elide: Text.ElideRight
            textFormat: Text.StyledText
        }
    }
}
