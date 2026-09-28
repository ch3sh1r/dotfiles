import QtQuick
import Quickshell
import Quickshell.Io

// A small JSON object persisted under Quickshell's state directory.
Scope {
    id: root

    required property string fileName
    property var values: ({})

    function set(key: string, value): void {
        let next = Object.assign({}, root.values);
        next[key] = value;
        root.values = next;
        file.setText(JSON.stringify(next, null, 2) + "\n");
    }

    FileView {
        id: file
        path: Quickshell.statePath(root.fileName)
        blockLoading: true
        printErrors: false
        onLoaded: {
            try {
                root.values = JSON.parse(text() || "{}");
            } catch (e) {
                root.values = {};
            }
        }
        onFileChanged: reload()
    }
}
