import Crescent.Core
import Crescent.Main
import Crescent.Models
import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: root

    property bool isExplicitLogout: false
    property bool isAuthenticated: false

    width: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? Screen.width : Screen.width * 0.75
    height: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? Screen.height : Screen.height * 0.75
    visible: true
    title: "Crescent"
    color: Theme.palette.background

    FontLoader {
        id: iconFont
        source: "qrc:/icons/CrescentIcons.ttf"
    }

    Connections {
        function onUserAuthenticated() {
            stackView.push("HomePage.qml");
            userAvatar.visible = true;
            usernameText.visible = true;
            root.isAuthenticated = true;
            chatsLoader.active = true;
            chatsLoader.Layout.fillHeight = true;
            chatsLoader.Layout.preferredWidth = root.width * 0.25;
            UserManager.get_me();
        }

        function onUserDeaunthenticated() {
            stackView.push("AuthPage.qml");
            userAvatar.visible = false;
            usernameText.visible = false;
            root.isAuthenticated = false;
            chatsLoader.active = false;
            chatsLoader.Layout.fillHeight = false;
            chatsLoader.Layout.preferredWidth = 0;
        }

        function onAuthError(errorMsg) {
            popup.popMessage = errorMsg;
            popup.open();
        }

        target: AuthManager
    }

    Connections {
        function onProfileReceived() {
            usernameText.text = UserManager.username();
            userAvatar.source = "data:image/png;base64," + UserManager.avatar();
        }

        function onErrorOccurred(error) {
            popup.popMessage = error;
            popup.open();
        }

        target: UserManager
    }

    MessageModel {
        id: messageModel
    }

    Popup {
        id: popup
        property alias popMessage: message.text

        z: 100
        y: (root.height - 95)
        modal: true
        focus: true
        closePolicy: Popup.CloseOnPressOutside
        onOpened: popupClose.start()

        Text {
            id: message
            anchors.centerIn: parent
            font.pointSize: 12
            wrapMode: Text.Wrap
            color: Theme.palette.textPrimary
        }

        background: Rectangle {
            implicitWidth: root.width
            implicitHeight: 40
            color: Theme.palette.errorBackground
        }
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
                width: parent.width
                onChatSelected: (chatId, chatName) => {
                    messageModel.chatId = chatId;
                    stackView.push("qrc:/Crescent/Main/ChatPage.qml", {
                        "chatId": chatId,
                        "chatName": chatName
                    });
                }
            }
        }

        Loader {
            id: chatsLoader
            Layout.preferredWidth: root.width * 0.25
            Layout.maximumWidth: 300
            Layout.fillHeight: true
            active: false
            visible: isAuthenticated
            sourceComponent: chatsListComponent
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.palette.secondary
            bottomLeftRadius: 10
            bottomRightRadius: 10
            clip: true

            StackView {
                id: stackView
                z: 10
                initialItem: "qrc:/Crescent/Main/AuthPage.qml"
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

    header: Rectangle {
    id: header
    height: 50
    width: root.width
    color: Theme.palette.primary

    RowLayout {
        anchors.fill: parent
        spacing: 10

        Text {
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            font.family: iconFont.name
            text: "\ue90d"
            color: Theme.palette.logoHeader
            font.pixelSize: 36
            renderType: Text.QtRendering
            antialiasing: true
            smooth: true
            layer.enabled: true
            layer.smooth: true

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: stackView.push("qrc:/Crescent/Main/HomePage.qml")
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Item {
            id: usernameContainer
            width: usernameText.width ? usernameText.width + 10 : 150
            height: 20

            Rectangle {
                id: shimmerRect
                anchors.fill: parent
                visible: usernameText.text === "" && usernameText.visible
                layer.enabled: true
                layer.smooth: true
                clip: true
                color: Theme.palette.background

                Rectangle {
                    id: shimmer
                    width: parent.width * 3
                    height: parent.height
                    color: Theme.palette.textDisabled
                    radius: 6
                    x: -width / 2
                    y: 0
                    opacity: 0.1

                    NumberAnimation on x {
                        from: -width / 2
                        to: width / 2
                        duration: 1500
                        loops: Animation.Infinite
                        running: shimmerRect.visible
                    }
                }
            }

            Text {
                id: usernameText
                anchors.centerIn: parent
                text: ""
                color: Theme.palette.textPrimary
                font.pixelSize: 24
                renderType: Text.QtRendering
                antialiasing: true
                layer.enabled: true
                visible: text !== ""
            }
        }

        Item {
            id: avatarContainer
            Layout.bottomMargin: -20
            Layout.rightMargin: 20
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: height
            Layout.alignment: Qt.AlignVCenter

            Image {
                id: userAvatar
                anchors.fill: parent
                source: ""
                visible: false
                antialiasing: true
                smooth: true
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
            }

            MultiEffect {
                anchors.fill: userAvatar
                source: userAvatar
                maskEnabled: true
                maskSource: mask
                antialiasing: true
            }

            Item {
                id: mask
                width: userAvatar.width
                height: userAvatar.height
                layer.enabled: true
                visible: false

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "black"
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: menu.open()
            }
        }
    }

    // Menu {
    //     id: menu
    //     y: header.height
    //     x: root.width - implicitWidth - 10
    //     width: implicitWidth
    //     z: 100

    //     MenuItem {
    //         text: qsTr("Select Theme")
    //         onClicked: selectThemeMenu.open()
    //         Menu {
    //             id: selectThemeMenu
    //             MenuItem { 
    //                 text: "Dark" 
    //                 onClicked: Theme.loadNamedTheme("Dark") 
    //             }
    //             MenuItem { 
    //                 text: "Light" 
    //                 onClicked: Theme.loadNamedTheme("Light") 
    //             }
    //             MenuItem { 
    //                 text: "Ice" 
    //                 onClicked: Theme.loadNamedTheme("Ice") 
    //             }
    //             MenuItem { 
    //                 text: "Paper" 
    //                 onClicked: Theme.loadNamedTheme("Paper") 
    //             }
    //             MenuItem { 
    //                 text: "Acid" 
    //                 onClicked: Theme.loadNamedTheme("Acid") 
    //             }
    //         }
    //     }

    //     MenuItem {
    //         text: qsTr("Sign out")
    //         onClicked: {
    //             root.isExplicitLogout = true
    //             AuthManager.signOutUser()
    //         }
    //     }
    // }

    CrescentMenu {
        id: menu
    
        x: root.width - width - 10
        y: avatarContainer.height
    
        CrescentMenuItem {
            text: "Select Theme"
            hasSubMenu: true
            childMenu: themeMenu
    
            CrescentMenu {
                id: themeMenu
    
                CrescentMenuItem {
                    text: "Dark"
                    hasSubMenu: false
                    onClicked: Theme.loadNamedTheme("Dark")
                }
    
                CrescentMenuItem {
                    text: "Light"
                    hasSubMenu: false
                    onClicked: Theme.loadNamedTheme("Light")
                }
    
                CrescentMenuItem {
                    text: "Ice"
                    hasSubMenu: false
                    onClicked: Theme.loadNamedTheme("Ice")
                }
    
                CrescentMenuItem {
                    text: "Paper"
                    hasSubMenu: false
                    onClicked: Theme.loadNamedTheme("Paper")
                }
    
                CrescentMenuItem {
                    text: "Acid"
                    hasSubMenu: false
                    onClicked: Theme.loadNamedTheme("Acid")
                }
    
            }
    
        }
    
        CrescentMenuItem {
            text: qsTr("Sign out")
            hasSubMenu: false
            onClicked: {
                root.isExplicitLogout = true;
                AuthManager.signOutUser();
            }
        }
    
    }
}
}