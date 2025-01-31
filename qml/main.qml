import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls 2.15
import Crescent.Theme 1.0

import "components"

ApplicationWindow {
    id: root
    visible: true
    title: "Crescent"
    color: Theme.getColor("background")
    
    header: ToolBar {
        height: 40
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        id: header
        contentItem: Rectangle {
            anchors.fill: parent
            color: Theme.getColor("primary")
            RowLayout {
                anchors.fill: parent
                spacing: 10

                Image {
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    source: "qrc:/logos/crescent_long.svg"
                    fillMode: Image.PreserveAspectFit
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignLeft
                }
            }
        }
    }

    width: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? Screen.width : Screen.width * 0.75
    height: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? Screen.height : Screen.height * 0.75
    
    RowLayout {
        anchors.fill: parent

        ChatsList {
            id: chatsList
            Layout.fillHeight: true
            Layout.preferredWidth: root.width * 0.25
            onChatSelected: (chatId) => stackView.push("qrc:/qml/pages/ChatPage.qml", { chatId: chatId })
        }

        StackView {
            id: stackView
            initialItem: "qrc:/qml/pages/HomePage.qml"
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
