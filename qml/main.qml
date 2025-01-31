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
