import QtQuick
import QtQuick.Effects
import Quickshell.Wayland
import ".."
import "../components"

WlSessionLockSurface {
    id: root

    required property bool authenticating
    required property bool passwordVisible
    required property string keyboardLayout
    required property string message
    required property string pamMessage
    required property bool pamMessageIsError

    signal passwordEntered()
    signal passwordSubmitted(string password)
    signal passwordCancelled()

    color: "#000000"

    Rectangle {
        anchors.fill: parent
        color: "#000000"

        Image {
            anchors.fill: parent
            source: Qt.resolvedUrl("/home/ch3sh1r/.config/hypr/rune.png")
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
            text: root.keyboardLayout
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
                        if (event.text.length > 0)
                            root.passwordEntered();

                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.passwordSubmitted(password.text);
                            password.text = "";
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            password.text = "";
                            root.passwordCancelled();
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
                visible: root.message.length > 0 || root.pamMessage.length > 0
                text: root.message.length > 0 ? root.message : root.pamMessage.replace(/:\s*$/, "")
                color: root.pamMessageIsError || root.message.length > 0 ? Theme.warning : Theme.base04
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.menuFontSize
                wrapMode: Text.Wrap
            }
        }
    }
}
