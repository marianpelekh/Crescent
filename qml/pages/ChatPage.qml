import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import "../components"

Item {
    id: root 

    property string chatId
    property string chatName
    

    ColumnLayout {
        anchors.fill: parent

        Label {
            Layout.preferredHeight: 50
            Layout.fillWidth: true
            text: root.chatName
            font.bold: true
        }

        ListView {
            id: messageList
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: ListModel {
                ListElement { sender: "Tom"; text: "Hey!" }
                ListElement { sender: "You"; text: "Hi!" }
            }

            delegate: Message {
                sender: model.sender
                text: model.text
            }
            onModelChanged: positionViewAtEnd()
        }
    }
}
