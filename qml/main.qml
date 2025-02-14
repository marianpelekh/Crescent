import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import Crescent.Theme
import Crescent.Models

import "components"

ApplicationWindow {
    id: root
    width: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? Screen.width : Screen.width * 0.75
    height: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? Screen.height : Screen.height * 0.75
    visible: true
    title: "Crescent"
    color: Theme.getColor("background")

    signal logged(login: string, password: string)

    function redirectHome() {
        stackView.push("qrc:/qml/pages/HomePage.qml")
    }

    onLogged: (login, password) => {
        loginUser.receiveUserInfo(login, password);
    }

    Connections {
        target: loginUser
        function onLoginSucceed() {
            redirectHome();
            chatsLoader.active = true;
            chatsLoader.Layout.fillHeight = true;
            chatsLoader.Layout.preferredWidth = root.width * 0.25;
        }
        function onLoginFailed() {
            popup.popMessage = "Incorrect login or password. Try again.";
            popup.open()
        }
    }

    header: Rectangle {
        id: header
        height: 50
        width: root.width
        color: Theme.getColor("primary")
        RowLayout {
            anchors.fill: parent
            spacing: 10

            Image {
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                source: "qrc:/logos/crescent_long.svg"
                fillMode: Image.PreserveAspectFit
                Layout.preferredWidth: 150
                Layout.alignment: Qt.AlignLeft
            }
        }
    }

    MessageModel {
        id: messageModel
    }

    Popup {
        id: popup
        property alias popMessage: message.text

        background: Rectangle {
            implicitWidth: root.width
            implicitHeight: 60
            color: Theme.getColor("primary")
        }
        y: (root.height - 60)
        modal: true
        focus: true
        closePolicy: Popup.CloseOnPressOutside
        Text {
            id: message
            anchors.centerIn: parent
            font.pointSize: 12
            color: Theme.getColor("textPrimary")
        }
        onOpened: popupClose.start()
    }

    Timer {
        id: popupClose
        interval: 2000
        onTriggered: popup.close()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        Component {
            id: chatsListComponent

            ChatsList {
                id: chatsList
                onChatSelected: (chatId, chatName) => {
                    messageModel.chatId = chatId;
                    stackView.push("qrc:/qml/pages/ChatPage.qml", { chatId: chatId, chatName: chatName });

                }
            }
        }

        Loader {
            id: chatsLoader
            active: false
            Layout.fillHeight: false
            Layout.preferredWidth: 0
            sourceComponent: chatsListComponent
        } 

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.getColor("secondary")
            bottomLeftRadius: 10 
            bottomRightRadius: 10 
            clip: true
            StackView {
                id: stackView
                initialItem: "qrc:/qml/pages/AuthPage.qml"
                anchors.fill: parent
                pushEnter: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
                pushExit: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 1
                        to: 0 
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
                popEnter: Transition {
                    PropertyAnimation {
                       property: "opacity"
                        from: 0
                        to: 1
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
                popExit: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
}
