pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland

Scope {
    id: root

    property string pendingPassword: ""
    property string enteredPassword: ""
    property int passwordCursorPosition: 0
    property string message: ""
    property string keyboardLayout: ""
    property bool passwordVisible: false
    property bool authenticating: false
    property int clearSequence: 0
    property bool recovering: false
    property bool stateFileError: false
    property string lockStatus: "unlocked"

    onClearSequenceChanged: {
        root.enteredPassword = "";
        root.passwordCursorPosition = 0;
    }

    function hideInterface(): void {
        inputIdle.stop();
        messageTimeout.stop();
        root.message = "";
        root.passwordVisible = false;
        root.clearSequence++;
    }

    function inputActivity(): void {
        if (root.authenticating)
            return;
        if (lockState.requested && sessionLock.locked && sessionLock.secure)
            dpmsOffDelay.restart();
        messageTimeout.stop();
        root.message = "";
        root.passwordVisible = true;
        inputIdle.restart();
    }

    function showMessage(text: string): void {
        inputIdle.stop();
        root.clearSequence++;
        root.passwordVisible = true;
        root.message = text;
        messageTimeout.restart();
    }

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

        root.hideInterface();
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

        inputIdle.stop();
        messageTimeout.stop();
        root.pendingPassword = password;
        root.message = "";
        root.passwordVisible = true;
        root.clearSequence++;
        root.authenticating = pam.start();
        if (!root.authenticating) {
            root.pendingPassword = "";
            root.showMessage("AUTH UNAVAILABLE");
        }
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

    GlobalShortcut {
        appid: "quickshell"
        name: "lock"
        description: "Lock the session"
        onPressed: root.lock()
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
                    root.showMessage("LOCK SECURITY ERROR");
                    root.lockStatus = "error: refusing insecure unlock";
                    return;
                }

                dpmsOffDelay.stop();
                root.hideInterface();
                root.recovering = false;
                lockState.requested = false;
                root.lockStatus = "unlocked";
                dpmsOn.running = true;
                lockStateFile.setText("");
            } else if (result === PamResult.MaxTries) {
                root.showMessage("TOO MANY ATTEMPTS");
            } else if (result === PamResult.Error) {
                root.showMessage("AUTH ERROR");
            } else {
                root.showMessage("ACCESS DENIED");
            }
        }

        onError: {
            root.authenticating = false;
            root.pendingPassword = "";
            root.showMessage("AUTH ERROR");
        }
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
            // Notifications can arrive while the lock is being released.
            if (!lockState.requested || !sessionLock.locked) {
                dpmsOffDelay.stop();
                return;
            }
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

        LockSurface {
            authenticating: root.authenticating
            passwordVisible: root.passwordVisible
            keyboardLayout: root.shortKeyboardLayout()
            message: root.message
            clearSequence: root.clearSequence
            passwordText: root.enteredPassword
            passwordCursorPosition: root.passwordCursorPosition

            onPasswordEntered: root.inputActivity()
            onPasswordEdited: (text, cursorPosition) => {
                root.enteredPassword = text;
                root.passwordCursorPosition = cursorPosition;
            }
            onPasswordCursorMoved: position => root.passwordCursorPosition = position
            onPasswordSubmitted: password => root.authenticate(password)
            onPasswordCancelled: root.hideInterface()
        }
    }

    Timer {
        id: inputIdle
        interval: 8000
        repeat: false
        onTriggered: root.hideInterface()
    }

    Timer {
        id: messageTimeout
        interval: 4000
        repeat: false
        onTriggered: {
            if (!root.authenticating)
                root.hideInterface();
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
        onTriggered: {
            if (lockState.requested && sessionLock.locked && sessionLock.secure && !root.authenticating)
                dpmsOff.running = true;
        }
    }

    Process {
        id: dpmsOff
        command: ["hyprctl", "dispatch", "hl.dsp.dpms(\"off\")"]
        // An off command already in flight must not win over an unlock.
        onExited: {
            if (!lockState.requested || !sessionLock.locked)
                dpmsOn.running = true;
        }
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
