import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Crescent.Theme 1.0
import Crescent.Models
import "../components"


Item {
    id: root 

    property string chatId: "0"
    property string chatName: "Private chat"

    // function getMessagesForChat(id) {
    //     var messages = {
    //         "1": [
    //             { sender: root.chatName, text: "Hello!" },
    //             { sender: "You", text: "Hey there!" }
    //         ],
    //         "2": [
    //             { sender: root.chatName, text: "How's it going?" },
    //             { sender: "You", text: "All good, you?" }
    //         ],
    //         "3": [
    //             { sender: root.chatName, text: "Ready for the meeting? We found new feature to be implemented into our project, hope you'll check it as soon as possible." },
    //             { sender: "You", text: "Yes, let's start!" },
    //             { sender: "You", text: "Okay, I'll start." }
    //         ]
    //     };
    //     return messages[id] || [];
    // }

    MessageModel {
        id: messageModel
        chatId: root.chatId
    }

    ColumnLayout {
        anchors.fill: parent
        Rectangle {
            Layout.preferredHeight: chatLabel.height + 10
            Layout.fillWidth: true
            color: Theme.getColor("tertiary")

            Label {
                id: chatLabel
                text: root.chatName
                color: Theme.getColor("textPrimary")
                font.pixelSize: 16
                font.bold: true
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
            }
        }

       ListView {
            id: messageList
            Layout.margins: 10
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: messageModel

            delegate: Message {
                sender: model.sender
                text: model.text
            }

            onModelChanged: positionViewAtEnd()
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            clip: true
            bottomLeftRadius: 10
            bottomRightRadius: 10
            color: Theme.getColor("primary")

            RowLayout {
                anchors.fill: parent
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "transparent" 
                    radius: 5

                    TextInput {
                        id: messageInput
                        width: parent.width
                        height: parent.height
                        color: Theme.getColor("textPrimary")
                        font.pixelSize: 14
                        leftPadding: 5
                        rightPadding: 5
                        verticalAlignment: TextInput.AlignVCenter
                        clip: true

                        property string placeholder: "Type a message..."
                        onTextChanged: messagePlaceholder.visible = text.length === 0

                        Label {
                            id: messagePlaceholder
                            text: messageInput.placeholder
                            color: Theme.getColor("textDisabled")
                            font.pixelSize: 14
                            anchors.fill: parent
                            verticalAlignment: Label.AlignVCenter
                            leftPadding: 5
                            visible: messageInput.text.length === 0
                        }
                    }
                }

                MouseArea {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    onClicked: {
                        console.log("Message sent:", messageInput.text);
                        messageModel.addMessage("You", messageInput.text);
                        messageInput.text = "";
                    }

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/icons/send.svg"
                        fillMode: Image.PreserveAspectFit
                        width: 24
                        height: 24
                        smooth: true
                        layer.enabled: true
                    }
                }
            }
        }    
    }
}
