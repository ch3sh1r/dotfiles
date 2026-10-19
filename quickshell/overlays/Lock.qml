pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import "../services"

// Session lock controller: keep PAM, compositor security, recovery and DPMS
// together so an unlock can only follow successful authentication of a secure
// lock. LockSurface renders input; KeyboardLayoutService tracks its layout.
Scope {
    id: root

    // Input is shared across outputs; PAM gets a separate copy during a request.
    property string pendingPassword: ""
    property string enteredPassword: ""
    property int passwordCursorPosition: 0
    property string message: ""
    property bool passwordVisible: false
    property bool authenticating: false
    property int clearSequence: 0
    // Recovery and diagnostics describe the lock independently of its input UI.
    property bool recovering: false
    property bool stateFileError: false
    property string lockStatus: "unlocked"

    onClearSequenceChanged: {
        root.enteredPassword = "";
        root.passwordCursorPosition = 0;
    }

    // Hiding the editor clears secrets without releasing the session lock.
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

    // Refuse new locks when authentication or real Wayland outputs are absent.
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
        keyboardLayoutService.refresh();
        return true;
    }

    // A disk marker also survives process restarts, unlike reload-only state.
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
        keyboardLayoutService.refresh();
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

    // Submit one PAM conversation at a time and clear the visible editor first.
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

    // sleep-lock relies on isLocked() confirming compositor security, not intent.
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

    // Preserve object identity and requested state during a QML reload.
    PersistentProperties {
        id: lockState
        reloadableId: "sessionLockState"

        property bool requested: false
    }

    // Check PAM availability before accepting a request to lock.
    FileView {
        id: pamConfigFile
        path: pam.configDirectory + "/" + pam.config
        blockLoading: true
        printErrors: false
    }

    // Persist intent synchronously before locking; a write failure aborts it.
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

    // Only successful PAM completion on a secure lock may release it.
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

    // Layout tracking is independent of authentication and input state.
    KeyboardLayoutService { id: keyboardLayoutService }

    // Recovery may need to wait for the compositor to enumerate outputs.
    Connections {
        target: Hyprland.monitors

        function onValuesChanged(): void {
            root.recoverLock();
        }
    }

    // The compositor confirms security asynchronously; requested alone is insufficient.
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
            keyboardLayout: keyboardLayoutService.shortLayout
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

    // UI timers hide input/messages while leaving the lock active.
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

    // Give startup outputs time to appear; report an unconfirmed lock after 5 s.
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

    // Blank only a confirmed lock; input postpones blanking and PAM suspends it.
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
        command: ["hyprctl", "dispatch", "hl.dsp.dpms({ action = \"off\" })"]
        // An off command already in flight must not win over an unlock.
        onExited: {
            if (!lockState.requested || !sessionLock.locked)
                dpmsOn.running = true;
        }
    }

    Process {
        id: dpmsOn
        command: ["hyprctl", "dispatch", "hl.dsp.dpms({ action = \"on\" })"]
    }

    // Reconcile reload-preserved state with the marker from a previous process.
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
