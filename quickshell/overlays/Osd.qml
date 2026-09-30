import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../components"

// On-screen display for volume and brightness (and short messages), shown
// bottom-center on the focused monitor. Visual only: the input mask is empty
// so it never takes clicks from the window underneath.
//
//   qs ipc call osd show brightness 40
//   qs ipc call osd message microphone-muted "Microphone muted"
Scope {
    id: root

    property bool opened: false
    property string icon: ""
    property string message: ""
    property int percent: 0
    readonly property bool hasProgress: root.message.length === 0
    readonly property int duration: 1200

    function iconFor(name: string, percent: int): string {
        switch (name) {
        case "volume-muted":
            return "󰖁";
        case "volume-low":
            return "󰕿";
        case "volume-medium":
            return "󰖀";
        case "volume-high":
            return "󰕾";
        case "microphone":
            return "󰍬";
        case "microphone-muted":
            return "󰍭";
        case "brightness":
            return "󰃠";
        case "stay-awake":
            return "󰅶";
        case "idle":
            return "󰒲";
        }
        if (name.length > 0)
            return name;
        if (percent <= 0)
            return "󰖁";
        if (percent < 34)
            return "󰕿";
        if (percent < 67)
            return "󰖀";
        return "󰕾";
    }

    function focusedScreen() {
        let name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
        let screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++) {
            if (screens[i].name === name)
                return screens[i];
        }
        return screens.length > 0 ? screens[0] : null;
    }

    function present(): void {
        // Pick the screen before mapping so a fresh OSD opens where the cursor is.
        if (!root.opened)
            panel.screen = root.focusedScreen();
        root.opened = true;
        hideTimer.restart();
    }

    function show(icon: string, percent: int): void {
        root.message = "";
        root.percent = Math.max(0, Math.min(100, percent));
        root.icon = root.iconFor(icon, root.percent);
        root.present();
    }

    function showMessage(icon: string, text: string): void {
        root.message = text;
        root.icon = root.iconFor(icon, 100);
        root.present();
    }

    function close(): void {
        hideTimer.stop();
        root.opened = false;
    }

    Timer {
        id: hideTimer
        interval: root.duration
        onTriggered: root.opened = false
    }

    IpcHandler {
        target: "osd"

        function show(icon: string, percent: int): void { root.show(icon, percent); }
        function message(icon: string, text: string): void { root.showMessage(icon, text); }
        function close(): void { root.close(); }
    }

    PanelWindow {
        id: panel

        visible: root.opened
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        mask: Region {}

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-osd"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors.bottom: true
        margins.bottom: 64
        implicitWidth: card.implicitWidth
        implicitHeight: card.implicitHeight

        Rectangle {
            id: card

            readonly property int pad: Theme.tooltipPadX + 2
            readonly property int barWidth: 140

            implicitWidth: row.implicitWidth + card.pad * 2
            implicitHeight: row.implicitHeight + Theme.tooltipPadY * 2
            radius: Theme.radius * 2
            color: Theme.bg
            border.width: 1
            border.color: Theme.base02

            SunsetTint {
                radius: card.radius
            }

            Row {
                id: row
                anchors.centerIn: parent
                spacing: Theme.tooltipPadX

                IconText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.icon
                    font.pixelSize: Theme.menuTitleFontSize + 4
                    color: Theme.fgBright
                }

                Rectangle {
                    visible: root.hasProgress
                    anchors.verticalCenter: parent.verticalCenter
                    width: card.barWidth
                    height: 6
                    radius: height / 2
                    color: Theme.base02

                    Rectangle {
                        width: parent.width * root.percent / 100
                        height: parent.height
                        radius: parent.radius
                        color: Theme.accent

                        Behavior on width {
                            NumberAnimation { duration: 80 }
                        }
                    }
                }

                Label {
                    visible: root.hasProgress
                    anchors.verticalCenter: parent.verticalCenter
                    width: valueMetrics.width
                    horizontalAlignment: Text.AlignRight
                    text: root.percent + "%"
                    font.pixelSize: Theme.menuFontSize
                    font.bold: true
                    color: Theme.fgBright
                }

                Label {
                    visible: !root.hasProgress
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.message
                    font.pixelSize: Theme.menuFontSize
                    font.bold: true
                    color: Theme.fgBright
                }
            }

            // Widest readout, so the digits do not jitter between 9% and 100%.
            TextMetrics {
                id: valueMetrics
                font.family: Theme.font
                font.pixelSize: Theme.menuFontSize
                font.bold: true
                text: "100%"
            }
        }
    }
}
