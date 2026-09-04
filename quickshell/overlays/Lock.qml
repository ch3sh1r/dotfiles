import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import ".."
import "../components"

Scope {
    id: root

    property string pendingPassword: ""
    property string message: ""
    property string keyboardLayout: ""
    property bool passwordVisible: false
    property bool authenticating: false
    property bool recovering: false
    property bool stateFileError: false
    property string lockStatus: "unlocked"

    function pamConfigured(): bool {
        return pam.config.length > 0
            && pam.configDirectory.length > 0
            && pamConfigFile.text().trim().length > 0;
    }

    function waylandOutputCount(): int {
        if ((Quickshell.env("WAYLAND_DISPLAY") || "").length === 0)
            return 0;

        let screens = Quickshell.screens;
        let count = 0;

        for (let i = 0; i < screens.length; i++) {
            let screen = screens[i];
            if (screen && screen.name.length > 0 && screen.width > 0 && screen.height > 0)
                count++;
        }

        return count;
    }

    function lock(): bool {
        if (sessionLock.secure)
            return true;
        if (lockState.requested) {
            root.lockStatus = sessionLock.locked ? "locking" : "error: lock request failed";
            return false;
        }
        if (!root.pamConfigured()) {
            root.lockStatus = "error: PAM is not configured";
            console.error("Refusing to lock: PAM configuration is unavailable");
            return false;
        }
        if (root.waylandOutputCount() === 0) {
            root.lockStatus = "error: no Wayland outputs";
            console.error("Refusing to lock: no real Wayland outputs are available");
            return false;
        }

        root.message = "";
        root.passwordVisible = false;
        root.recovering = false;
        root.lockStatus = "locking";
        root.stateFileError = false;
        lockStateFile.setText("locked\n");
        if (root.stateFileError) {
            root.lockStatus = "error: cannot persist lock state";
            return false;
        }

        lockState.requested = true;
        secureConfirmation.restart();
        keyboardLayoutProc.running = true;
        return true;
    }

    function recoverLock(): void {
        if (lockState.requested || lockStateFile.text().trim() !== "locked")
            return;
        if (!root.pamConfigured()) {
            root.lockStatus = "error: recovery requires PAM";
            console.error("Cannot recover the session lock: PAM configuration is unavailable");
            return;
        }
        if (root.waylandOutputCount() === 0) {
            root.lockStatus = "recovering: waiting for a Wayland output";
            return;
        }

        root.recovering = true;
        root.lockStatus = "recovering";
        lockState.requested = true;
        secureConfirmation.restart();
        keyboardLayoutProc.running = true;
    }

    function diagnosticStatus(): string {
        return JSON.stringify({
            state: root.lockStatus,
            locked: sessionLock.locked && sessionLock.secure,
            requested: lockState.requested,
            secure: sessionLock.secure,
            pamConfigured: root.pamConfigured(),
            waylandOutputs: root.waylandOutputCount(),
            recovering: root.recovering
        });
    }

    function authenticate(password: string): void {
        if (root.authenticating || password.length === 0 || !sessionLock.secure)
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

    function shortKeyboardLayout(): string {
        let layout = root.keyboardLayout.toLowerCase();

        if (layout.indexOf("russian") !== -1 || layout.indexOf("ru") === 0)
            return "RU";
        if (layout.indexOf("english") !== -1 || layout.indexOf("us") !== -1)
            return "EN";

        return root.keyboardLayout.length >= 2 ? root.keyboardLayout.slice(0, 2).toUpperCase() : "--";
    }

    IpcHandler {
        target: "lock"

        function lock(): bool { return root.lock(); }
        function isLocked(): bool { return sessionLock.locked && sessionLock.secure; }
        function status(): string { return root.diagnosticStatus(); }
    }

    PersistentProperties {
        id: lockState
        reloadableId: "sessionLockState"

        property bool requested: false
    }

    FileView {
        id: pamConfigFile
        path: pam.configDirectory + "/" + pam.config
        blockLoading: true
        printErrors: false
    }

    FileView {
        id: lockStateFile
        path: Quickshell.statePath("session-lock")
        blockLoading: true
        blockWrites: true
        printErrors: false

        onSaved: root.stateFileError = false
        onSaveFailed: error => {
            root.stateFileError = true;
            console.error("Cannot persist session lock state: " + FileViewError.toString(error));
        }
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
                if (!sessionLock.locked || !sessionLock.secure) {
                    root.message = "Lock security was not confirmed";
                    root.lockStatus = "error: refusing insecure unlock";
                    return;
                }

                dpmsOffDelay.stop();
                dpmsOn.running = true;
                root.passwordVisible = false;
                root.recovering = false;
                root.message = "";
                lockState.requested = false;
                lockStateFile.setText("");
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

    Connections {
        target: Hyprland.monitors

        function onValuesChanged(): void {
            root.recoverLock();
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
        reloadableId: "sessionLock"
        locked: lockState.requested

        onSecureChanged: {
            if (secure) {
                secureConfirmation.stop();
                root.recovering = false;
                root.lockStatus = "locked";
                dpmsOffDelay.restart();
            } else if (locked && lockState.requested) {
                root.lockStatus = "error: compositor lock is not secure";
                dpmsOffDelay.stop();
            }
        }

        onLockedChanged: {
            if (locked) {
                root.lockStatus = secure ? "locked" : (root.recovering ? "recovering" : "locking");
                if (!secure)
                    secureConfirmation.restart();
            } else {
                let requestFailed = lockState.requested;
                if (requestFailed && !secure)
                    lockState.requested = false;

                secureConfirmation.stop();
                dpmsOffDelay.stop();
                dpmsOn.running = true;
                root.lockStatus = requestFailed ? "error: session lock unavailable" : "unlocked";
            }
        }

        WlSessionLockSurface {
            id: surface
            color: "#000000"

            Rectangle {
                anchors.fill: parent
                color: "#000000"

                Image {
                    id: wallpaper
                    anchors.fill: parent
                    source: Qt.resolvedUrl("../../hypr/rune.png")
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
                    id: blackout
                    anchors.fill: parent
                    color: "#000000"
                    opacity: 0

                    NumberAnimation on opacity {
                        from: 0
                        to: 1
                        duration: 700
                        easing.type: Easing.OutCubic
                    }
                }

                Label {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 24
                    anchors.rightMargin: 28
                    visible: root.passwordVisible || root.authenticating
                    text: root.shortKeyboardLayout()
                    color: Theme.base04
                    font.pixelSize: Theme.menuFontSize
                    font.bold: true
                }

                Column {
                    width: Math.min(320, parent.width - 48)
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 92
                    spacing: 10

                    Label {
                        width: parent.width
                        visible: root.passwordVisible || root.authenticating
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
                        visible: root.passwordVisible || root.authenticating
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
                                if (event.text.length > 0) {
                                    root.message = "";
                                    root.passwordVisible = true;
                                }

                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    root.authenticate(password.text);
                                    password.text = "";
                                    root.passwordVisible = false;
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Escape) {
                                    password.text = "";
                                    root.passwordVisible = false;
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
                        visible: root.message.length > 0 || pam.message.length > 0
                        text: root.message.length > 0 ? root.message : pam.message.replace(/:\s*$/, "")
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
        id: recoveryDelay
        interval: 250
        repeat: false
        onTriggered: root.recoverLock()
    }

    Timer {
        id: secureConfirmation
        interval: 5000
        repeat: false
        onTriggered: {
            if (lockState.requested && !sessionLock.secure) {
                root.lockStatus = sessionLock.locked
                    ? "error: compositor did not confirm a secure lock"
                    : "error: session lock unavailable";
                console.error(root.lockStatus);
            }
        }
    }

    Timer {
        id: dpmsOffDelay
        interval: 30000
        repeat: false
        onTriggered: dpmsOff.running = true
    }

    Process {
        id: dpmsOff
        command: ["hyprctl", "dispatch", "hl.dsp.dpms(\"off\")"]
    }

    Process {
        id: dpmsOn
        command: ["hyprctl", "dispatch", "hl.dsp.dpms(\"on\")"]
    }

    Component.onCompleted: {
        Hyprland.refreshMonitors();

        if (lockState.requested) {
            root.recovering = !sessionLock.secure;
            root.lockStatus = sessionLock.secure ? "locked" : "recovering";
            if (!sessionLock.secure)
                secureConfirmation.restart();
        } else if (lockStateFile.text().trim() === "locked") {
            root.recovering = true;
            root.lockStatus = "recovering";
            recoveryDelay.start();
        }
    }
}
