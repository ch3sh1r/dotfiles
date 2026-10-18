pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "../components"

WlSessionLockSurface {
    id: root

    required property bool authenticating
    required property bool passwordVisible
    required property string keyboardLayout
    required property string message
    required property int clearSequence
    required property string passwordText

    readonly property bool interfaceVisible: passwordVisible || authenticating
    readonly property color frameColor: message.length > 0 ? Theme.pink : Theme.accent

    signal passwordEntered()
    signal passwordEdited(string text)
    signal passwordSubmitted(string password)
    signal passwordCancelled()

    color: Theme.lockBackground

    onClearSequenceChanged: password.clear()
    onPasswordTextChanged: syncPassword()

    function syncPassword(): void {
        if (password.text !== root.passwordText) {
            password.text = root.passwordText;
            password.cursorPosition = password.length;
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // Opacity keeps the editor focused even when the screen is entirely black.
    // The first printable key is handled by TextInput itself, without replaying it.
    Item {
        id: panel
        width: Math.min(320, parent.width - 48)
        height: 254
        anchors.centerIn: parent
        opacity: root.interfaceVisible ? 1 : 0

        Row {
            anchors.top: parent.top
            spacing: 8

            Rectangle {
                width: 5
                height: 5
                anchors.verticalCenter: parent.verticalCenter
                color: root.frameColor
            }

            Label {
                text: "SESSION LOCKED"
                color: Theme.accent
                font.pixelSize: 11
                font.letterSpacing: 2
            }
        }

        Label {
            anchors.top: parent.top
            anchors.right: parent.right
            text: root.keyboardLayout
            color: Theme.cyan
            font.pixelSize: 11
            font.letterSpacing: 1
        }

        Rectangle {
            y: 25
            width: parent.width
            height: 1
            color: Theme.accent
            opacity: 0.45
        }

        Label {
            y: 43
            width: parent.width
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Theme.fgBright
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 48
            font.letterSpacing: 3
        }

        Label {
            y: 105
            width: parent.width
            text: Qt.formatDateTime(clock.date, "yyyy.MM.dd")
            color: Theme.base03
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 12
            font.letterSpacing: 2
        }

        Item {
            id: inputFrame
            y: 150
            width: parent.width
            height: 56

            // Four short brackets frame the input without a filled card.
            Repeater {
                model: 4

                delegate: Item {
                    required property int index
                    x: index % 2 === 0 ? 0 : inputFrame.width - width
                    y: index < 2 ? 0 : inputFrame.height - height
                    width: 12
                    height: 10

                    Rectangle {
                        width: parent.width
                        height: 1
                        y: parent.index < 2 ? 0 : parent.height - height
                        color: root.frameColor
                    }

                    Rectangle {
                        width: 1
                        height: parent.height
                        x: parent.index % 2 === 0 ? 0 : parent.width - width
                        color: root.frameColor
                    }
                }
            }

            Label {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: ">"
                color: root.frameColor
                font.pixelSize: Theme.menuInputFontSize
            }

            TextInput {
                id: password
                anchors.fill: parent
                anchors.leftMargin: 42
                anchors.rightMargin: 18
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.fgBright
                selectionColor: Theme.accent
                selectedTextColor: Theme.base00
                echoMode: TextInput.Password
                passwordCharacter: "*"
                passwordMaskDelay: 0
                readOnly: root.authenticating
                cursorVisible: root.interfaceVisible && activeFocus && !root.authenticating
                font.family: Theme.font
                font.pixelSize: Theme.menuInputFontSize
                font.letterSpacing: 3
                clip: true

                onTextEdited: {
                    root.passwordEdited(text);
                    root.passwordEntered();
                }

                Keys.onPressed: event => {
                    if (root.authenticating) {
                        event.accepted = true;
                        return;
                    }

                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.passwordSubmitted(password.text);
                        password.clear();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Escape) {
                        password.clear();
                        root.passwordCancelled();
                        event.accepted = true;
                    } else if (root.interfaceVisible || event.text.length > 0) {
                        root.passwordEntered();
                    }
                }

                Component.onCompleted: {
                    root.syncPassword();
                    forceActiveFocus();
                }
            }

            Label {
                anchors.centerIn: parent
                visible: password.text.length === 0
                text: root.authenticating ? "VERIFYING" : "PASSWORD"
                color: Theme.base03
                font.pixelSize: 11
                font.letterSpacing: 2
            }
        }

        Label {
            y: 226
            width: parent.width
            text: root.message.length > 0 ? root.message : root.authenticating ? "AUTHENTICATING" : ""
            color: root.message.length > 0 ? Theme.pink : Theme.base03
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 10
            font.letterSpacing: 1
            wrapMode: Text.Wrap
        }
    }
}
