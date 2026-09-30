import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import ".."
import "../components"

// Persistent status for the external Voxtype daemon. Unlike a desktop toast,
// this stays visible until Voxtype leaves recording/transcribing state.
PanelWindow {
    id: root

    property string state: "idle"
    property int elapsedSeconds: 0
    readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR") || ""
    readonly property bool recording: state === "recording"
    readonly property bool transcribing: state === "transcribing"
    readonly property color stateColor: recording ? Theme.urgent : Theme.warning

    function setState(value: string): void {
        const next = value.trim();
        if (next === root.state)
            return;
        root.state = next;
        root.elapsedSeconds = 0;
    }

    function twoDigits(value: int): string {
        return value < 10 ? "0" + value : String(value);
    }

    function focusedScreen() {
        const name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++) {
            if (screens[i].name === name)
                return screens[i];
        }
        return screens.length > 0 ? screens[0] : null;
    }

    screen: root.focusedScreen()
    visible: root.recording || root.transcribing
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    mask: Region {}

    anchors {
        top: true
        left: true
        right: true
    }
    margins.top: Theme.barHeight + 12
    implicitHeight: card.implicitHeight + 12

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-dictation"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    FileView {
        path: root.runtimeDir.length > 0 ? root.runtimeDir + "/voxtype/state" : "/voxtype/state"
        blockLoading: true
        printErrors: false
        watchChanges: true
        onLoaded: root.setState(text())
        onFileChanged: reload()
        onLoadFailed: root.setState("idle")
    }

    Timer {
        running: root.recording
        repeat: true
        interval: 1000
        onTriggered: root.elapsedSeconds++
    }

    Rectangle {
        id: card

        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: row.implicitWidth + 32
        implicitHeight: row.implicitHeight + 20
        radius: Theme.radius * 2
        color: Theme.bg
        border.width: 2
        border.color: root.stateColor

        SunsetTint {
            radius: card.radius
        }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 12

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.recording ? "󰍬" : "󰔟"
                font.family: Theme.iconFont
                font.pixelSize: 25
                color: root.stateColor
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Label {
                    text: root.recording ? "ИДЁТ ЗАПИСЬ" : "РАСПОЗНАВАНИЕ РЕЧИ"
                    font.pixelSize: Theme.menuTitleFontSize
                    font.bold: true
                    color: Theme.fgBright
                }

                Label {
                    text: root.recording
                        ? "Нажмите то же сочетание, чтобы завершить"
                        : "Обрабатываю запись…"
                    font.pixelSize: Theme.menuFontSize
                    color: Theme.fg
                }
            }

            Label {
                visible: root.recording
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    const minutes = Math.floor(root.elapsedSeconds / 60);
                    const seconds = root.elapsedSeconds % 60;
                    return root.twoDigits(minutes) + ":" + root.twoDigits(seconds);
                }
                font.pixelSize: Theme.menuTitleFontSize
                font.bold: true
                color: root.stateColor
            }
        }
    }
}
