import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts

Item {
    property string chatId

    ColumnLayout {
        anchors.fill: parent

        Label {
            text: "Chat ID: " + chatId
            font.bold: true
        }

        ListView {
            id: messageList
            Layout.fillHeight: true
            model: ListModel {
                ListElement { sender: "Tom"; text: "Hey!" }
                ListElement { sender: "You"; text: "Hi!" }
            }

            delegate: MessageBubble {
                sender: model.sender
                text: model.text
            }
        }
    }
}
