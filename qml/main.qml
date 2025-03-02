import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls 2.15
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

    FontLoader {
        id: iconFont
        source: "qrc:/icons/CrescentIcons.ttf"
    }
    
    Connections {
        target: networkManager

        function onLoginSuccess(token) {
            stackView.push("pages/HomePage.qml");
            networkManager.fetchUserProfile();
            chatsLoader.active = true;
            chatsLoader.Layout.fillHeight = true;
            chatsLoader.Layout.preferredWidth = root.width * 0.25;
        }

        function onProfileReceived(username, avatarUrl) {
            usernameText.text = username;
        }

        function onLoginFailed(error) {
            popup.popMessage = error
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

            Text {
                Layout.leftMargin: 10 
                Layout.rightMargin: 10 
                font.family: iconFont.name
                text: "\ue90d" 
                color: Theme.getColor("logoHeader") 
                font.pixelSize: 36
                renderType: Text.QtRendering
                antialiasing: true
                smooth: true
                layer.enabled: true
                layer.smooth: true
            }

            Text {
                id: usernameText
                Layout.leftMargin: 10 
                Layout.rightMargin: 10 
                text: ""//тут має бути отримане ім'я користувача 
                color: Theme.getColor("textPrimary") 
                font.pixelSize: 36
                renderType: Text.QtRendering
                antialiasing: true
                smooth: true
                layer.enabled: true
                layer.smooth: true

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
            implicitHeight: 40
            color: Theme.getColor("errorBackground")
        }
        y: (root.height - 95)
        modal: true
        focus: true
        closePolicy: Popup.CloseOnPressOutside
        Text {
            id: message
            anchors.centerIn: parent
            font.pointSize: 12
            wrapMode: Text.Wrap
            color: Theme.getColor("textPrimary")
        }
        onOpened: popupClose.start()
    }

    Timer {
        id: popupClose
        interval: 4000
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
