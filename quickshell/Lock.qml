import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland

Scope {
    id: root

    property string pendingPassword: ""
    property string message: ""
    property string keyboardLayout: ""
    property bool authenticating: false

    function lock(): void {
        root.message = "";
        sessionLock.locked = true;
        dpmsOffDelay.restart();
        keyboardLayoutProc.running = true;
    }

    function unlock(): void {
        pam.abort();
        dpmsOffDelay.stop();
        dpmsOn.running = true;
        root.pendingPassword = "";
        root.authenticating = false;
        sessionLock.locked = false;
    }

    function authenticate(password: string): void {
        if (root.authenticating || password.length === 0)
            return;

        root.pendingPassword = password;
        root.message = "";
        root.authenticating = pam.start();
        if (!root.authenticating)
            root.message = "Authentication unavailable";
    }

    function answerPam(): void {
        if (pam.responseRequired)
            pam.respond(root.pendingPassword);
    }

    function updateKeyboardLayout(text): void {
        try {
            let devices = JSON.parse(text.trim() || "{}");
            let keyboards = devices.keyboards || [];
            let fallback = "";

            for (let i = 0; i < keyboards.length; i++) {
                let layout = keyboards[i].active_keymap || "";
                if (layout.length === 0)
                    continue;

                if (fallback.length === 0)
                    fallback = layout;

                if (keyboards[i].main) {
                    root.keyboardLayout = layout;
                    return;
                }
            }

            root.keyboardLayout = fallback;
        } catch (e) {
            root.keyboardLayout = "";
        }
    }

    function updateKeyboardLayoutFromEvent(event): void {
        if (event.name !== "activelayout")
            return;

        let args = event.parse(2);
        if (args.length >= 2 && args[1].length > 0)
            root.keyboardLayout = args[1];
    }

    IpcHandler {
        target: "lock"

        function lock(): void { root.lock(); }
        function unlock(): void { root.unlock(); }
    }

    PamContext {
        id: pam
        config: "login"

        onPamMessage: root.answerPam()
        onResponseRequiredChanged: root.answerPam()

        onCompleted: result => {
            root.authenticating = false;
            root.pendingPassword = "";

            if (result === PamResult.Success) {
                sessionLock.locked = false;
                root.message = "";
            } else if (result === PamResult.MaxTries) {
                root.message = "Too many attempts";
            } else if (result === PamResult.Error) {
                root.message = "Authentication error";
            } else {
                root.message = "Authentication failed";
            }
        }

        onError: root.message = "Authentication error"
    }

    Connections {
        target: Hyprland

        function onRawEvent(event): void {
            root.updateKeyboardLayoutFromEvent(event);
        }
    }

    Process {
        id: keyboardLayoutProc
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.updateKeyboardLayout(this.text)
        }
    }

    WlSessionLock {
        id: sessionLock

        onSecureChanged: {
            if (secure)
                dpmsOffDelay.restart();
        }

        onLockedChanged: {
            if (locked) {
                dpmsOffDelay.restart();
            } else {
                dpmsOffDelay.stop();
                dpmsOn.running = true;
            }
        }

        WlSessionLockSurface {
            id: surface
            color: Theme.base00

            Rectangle {
                anchors.fill: parent
                color: Theme.base00

                Image {
                    id: wallpaper
                    anchors.fill: parent
                    source: "file:///home/ch3sh1r/.config/hypr/rune.png"
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    asynchronous: true
                    opacity: 0.55
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blurMax: 16
                        blur: 0.8
                        saturation: 0.45
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#aa282a36"
                }

                Column {
                    width: Math.min(320, parent.width - 48)
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 92
                    spacing: 10

                    Label {
                        width: parent.width
                        text: Qt.formatDateTime(new Date(), "hh:mm")
                        color: Theme.fgBright
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 42
                        font.bold: true
                    }

                    Rectangle {
                        width: 290
                        height: 60
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: Theme.radius
                        color: "#593c3836"
                        border.width: 2
                        border.color: password.activeFocus ? Theme.accent : "transparent"

                        TextInput {
                            id: password
                            anchors.fill: parent
                            anchors.leftMargin: 18
                            anchors.rightMargin: 18
                            verticalAlignment: TextInput.AlignVCenter
                            color: Theme.fgBright
                            selectionColor: Theme.accent
                            selectedTextColor: Theme.base00
                            echoMode: TextInput.Password
                            passwordCharacter: "*"
                            enabled: !root.authenticating
                            font.family: Theme.font
                            font.pixelSize: Theme.menuInputFontSize

                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    root.authenticate(password.text);
                                    password.text = "";
                                    event.accepted = true;
                                }
                            }

                            Component.onCompleted: forceActiveFocus()
                        }

                        Label {
                            anchors.centerIn: parent
                            visible: password.text.length === 0 && !password.activeFocus
                            text: root.authenticating ? "Checking" : "Password"
                            color: Theme.base04
                            font.pixelSize: Theme.menuFontSize
                        }
                    }

                    Label {
                        width: parent.width
                        text: "Layout: " + (root.keyboardLayout.length > 0 ? root.keyboardLayout : "unknown")
                        color: Theme.base04
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: Theme.menuFontSize
                    }

                    Label {
                        width: parent.width
                        visible: root.message.length > 0 || pam.message.length > 0
                        text: root.message.length > 0 ? root.message : pam.message
                        color: pam.messageIsError || root.message.length > 0 ? Theme.warning : Theme.base04
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: Theme.menuFontSize
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }

    Timer {
        id: dpmsOffDelay
        interval: 1000
        repeat: false
        onTriggered: dpmsOff.running = true
    }

    Process {
        id: dpmsOff
        command: ["hyprctl", "dispatch", "dpms", "off"]
    }

    Process {
        id: dpmsOn
        command: ["hyprctl", "dispatch", "dpms", "on"]
    }
}
