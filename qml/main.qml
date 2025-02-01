import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls 2.15
import Crescent.Theme

import "components"

ApplicationWindow {
    id: root
    width: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? Screen.width : Screen.width * 0.75
    height: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? Screen.height : Screen.height * 0.75
    visible: true
    title: "Crescent"
    color: Theme.getColor("background")

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
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        ChatsList {
            id: chatsList
            Layout.fillHeight: true
            Layout.preferredWidth: root.width * 0.25
            onChatSelected: (chatId, chatName) => stackView.push("qrc:/qml/pages/ChatPage.qml", { chatId: chatId, chatName: chatName })
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
                initialItem: "qrc:/qml/pages/HomePage.qml"
                anchors.fill: parent
            }
        }
    }
}
