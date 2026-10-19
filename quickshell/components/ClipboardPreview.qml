import QtQuick
import Quickshell.Io
import Quickshell.Widgets
import ".."

// Clipboard detail pane. The selector supplies the item and helper path;
// this component owns text decoding and discards replies for old selections.
Rectangle {
    id: preview

    required property var item
    required property string actionScript
    readonly property bool hasImage: !!item && (item.image || "").length > 0
    readonly property string textId: item && !hasImage ? item.id : ""
    property string requestedId: ""
    property string fullText: ""

    radius: Theme.radius
    color: Theme.base01
    border.width: 1
    border.color: Theme.base02
    clip: true

    // Coalesce changes during decoding; retry the newest ID after the process exits.
    function loadText(): void {
        fullText = "";
        textScroll.contentY = 0;
        if (textProc.running || textId.length === 0)
            return;
        requestedId = textId;
        textProc.command = ["bash", preview.actionScript, "clipboard", "preview", textId];
        textProc.running = true;
    }

    onTextIdChanged: Qt.callLater(preview.loadText)

    // A late reply must not overwrite the preview for a newer selection.
    Process {
        id: textProc
        stdout: StdioCollector {
            onStreamFinished: {
                if (preview.requestedId === preview.textId)
                    preview.fullText = this.text;
            }
        }
        onExited: Qt.callLater(() => {
            if (preview.requestedId !== preview.textId)
                preview.loadText();
        })
    }

    // Images use helper-generated cache files; text is decoded on demand.
    IconImage {
        anchors.fill: parent
        anchors.margins: 14
        visible: preview.hasImage
        source: preview.hasImage ? "file://" + preview.item.image : ""
        mipmap: true
    }

    Flickable {
        id: textScroll
        anchors.fill: parent
        anchors.margins: 14
        visible: !preview.hasImage
        contentWidth: width
        contentHeight: Math.max(height, previewText.implicitHeight)
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Label {
            id: previewText
            width: parent.width
            text: preview.fullText
            textFormat: Text.PlainText
            color: Theme.fgBright
            font.pixelSize: Theme.menuFontSize
            wrapMode: Text.Wrap
            verticalAlignment: Text.AlignTop
        }
    }

    Label {
        anchors.centerIn: parent
        visible: !preview.item
        text: "No selection"
        color: Theme.base03
        font.pixelSize: Theme.menuFontSize
    }
}
