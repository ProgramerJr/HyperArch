import QtQuick 2.15
import QtQuick.Controls 2.15
import SddmComponents 2.0

Rectangle {
    width: 2560; height: 1440
    color: "#090909"

    Image {
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.centerIn: parent
        width: 380; height: 300
        radius: 16
        color: "#cc0f0d0e"
        border.color: "#ff1e3c"
        border.width: 2

        Column {
            anchors.centerIn: parent
            spacing: 18
            width: parent.width - 60

            Text {
                text: "HyperArch"
                color: "#ff1e3c"
                font.pixelSize: 26
                font.family: "JetBrains Mono"
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: user
                width: parent.width
                text: userModel.lastUser
                placeholderText: "usuario"
                color: "#f3d6d9"
                background: Rectangle { color: "#090909"; radius: 8; border.color: "#8b0020" }
            }

            TextField {
                id: pass
                width: parent.width
                echoMode: TextInput.Password
                placeholderText: "contraseña"
                color: "#f3d6d9"
                focus: true
                background: Rectangle { color: "#090909"; radius: 8; border.color: "#8b0020" }
                Keys.onReturnPressed: sddm.login(user.text, pass.text, session.currentIndex)
            }

            Button {
                width: parent.width
                text: "Entrar"
                onClicked: sddm.login(user.text, pass.text, session.currentIndex)
                contentItem: Text {
                    text: parent.text; color: "#090909"
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                }
                background: Rectangle { color: "#ff1e3c"; radius: 8 }
            }

            ComboBox {
                id: session
                width: parent.width
                model: sessionModel
                currentIndex: sessionModel.lastIndex
                textRole: "name"
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() { pass.text = ""; pass.placeholderText = "contraseña incorrecta" }
    }
}
