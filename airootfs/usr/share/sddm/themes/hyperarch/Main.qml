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
        color: "#cc0d0f14"
        border.color: "#2f9bff"
        border.width: 2

        Column {
            anchors.centerIn: parent
            spacing: 18
            width: parent.width - 60

            TextField {
                id: user
                width: parent.width
                text: userModel.lastUser
                placeholderText: "usuario"
                color: "#d6e4f3"
                background: Rectangle { color: "#090909"; radius: 8; border.color: "#6d3cff" }
            }

            TextField {
                id: pass
                width: parent.width
                echoMode: TextInput.Password
                placeholderText: "contraseña"
                color: "#d6e4f3"
                focus: true
                background: Rectangle { color: "#090909"; radius: 8; border.color: "#6d3cff" }
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
                background: Rectangle { color: "#2f9bff"; radius: 8 }
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
