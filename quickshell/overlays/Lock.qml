import QtQuick
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

        LockSurface {
            authenticating: root.authenticating
            passwordVisible: root.passwordVisible
            keyboardLayout: root.shortKeyboardLayout()
            message: root.message
            pamMessage: pam.message
            pamMessageIsError: pam.messageIsError

            onPasswordEntered: {
                root.message = "";
                root.passwordVisible = true;
            }
            onPasswordSubmitted: password => {
                root.authenticate(password);
                root.passwordVisible = false;
            }
            onPasswordCancelled: root.passwordVisible = false
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
