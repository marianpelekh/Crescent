import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Crescent.Theme 1.0
import Crescent.Models
import "../components"


Item {
    id: root 

    property string chatId: "0"
    property string type: "chat"
    property string chatName: "Private chat"

    MessageModel {
        id: messageModel
        chatId: root.chatId
    }

    ColumnLayout {
        id: chatColumn
        anchors.fill: parent

        Rectangle {
            Layout.preferredHeight: chatLabel.height + 10
            Layout.fillWidth: true
            color: Theme.getColor("tertiary")
            z: 1

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

        ListView{
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
            Layout.preferredHeight: 45 > messageInput.implicitHeight + 5 ? 
            45 : messageInput.implicitHeight + 5 > chatColumn.height * 0.3 ? 
            chatColumn.height * 0.3 : messageInput.implicitHeight + 5
            clip: true
            bottomLeftRadius: 10
            bottomRightRadius: 10
            color: Theme.getColor("primary")

            RowLayout {
                anchors.fill: parent
                spacing: 10
                MouseArea {
                    Layout.preferredHeight: 22
                    Layout.preferredWidth: 22 
                    Layout.leftMargin: 10 
                    Layout.rightMargin: 0 
                    cursorShape: Qt.PointingHandCursor 

                    onClicked: {

                    } 

                    Text {
                        id: includeButton 
                        font.family: iconFont.name 
                        text: "\ue900"
                        color: Theme.getColor("textSecondary")
                        font.pixelSize: 22
                        renderType: Text.QtRendering
                        antialiasing: true
                        smooth: true
                        layer.enabled: true
                        layer.smooth: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40 > messageInput.implicitHeight ? 
                    40 : messageInput.implicitHeight > chatColumn.height * 0.3 ? 
                    chatColumn.height * 0.3 : messageInput.implicitHeight
                    color: "transparent" 
                    radius: 5
                    TextEdit {
                        id: messageInput
                        width: parent.width
                        height: parent.height
                        color: Theme.getColor("textPrimary")
                        font.pixelSize: 14
                        leftPadding: 10
                        rightPadding: 10
                        verticalAlignment: TextInput.AlignVCenter
                        wrapMode: TextEdit.Wrap
                        clip: true

                        property string placeholder: "Type a message..."
                        onTextChanged: messagePlaceholder.visible = text.length === 0

                        Keys.onReturnPressed: function(event) {
                            if (event.modifiers & Qt.ShiftModifier) {
                                messageInput.insert(messageInput.cursorPosition, "\n")
                            } else if (text.length > 0) {
                                console.log("Message sent:", text)
                                messageModel.addMessage("You", text)
                                text = ""
                            }
                            event.accepted = true
                        }

                        Label {
                            id: messagePlaceholder
                            text: messageInput.placeholder
                            color: Theme.getColor("textDisabled")
                            font.pixelSize: 14
                            anchors.fill: parent
                            verticalAlignment: Label.AlignVCenter
                            leftPadding: 10
                            visible: messageInput.text.length === 0
                        }
                    }

                }
                MouseArea {
                    Layout.preferredHeight: 22
                    Layout.preferredWidth: 22 
                    Layout.leftMargin: 10 
                    Layout.rightMargin: 10 
                    cursorShape: Qt.PointingHandCursor 

                    onClicked: {

                    } 

                    Text {
                        id: emojiButton 
                        font.family: iconFont.name 
                        text: "\ue903"
                        color: Theme.getColor("textSecondary")
                        font.pixelSize: 22
                        renderType: Text.QtRendering
                        antialiasing: true
                        smooth: true
                        layer.enabled: true
                        layer.smooth: true
                    }
                }

                MouseArea {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    Layout.rightMargin: 10
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        console.log("Message sent:", messageInput.text);
                        messageModel.addMessage("You", messageInput.text);
                        messageInput.text = "";
                        scaleAnimation.start();
                    }

                    Text {
                        id: sendButton
                        font.family: iconFont.name
                        text: "\ue906"
                        color: Theme.getColor("textPrimary")
                        font.pixelSize: 28
                        renderType: Text.QtRendering
                        antialiasing: true
                        smooth: true
                        layer.enabled: true
                        layer.smooth: true
                    }

                    ScaleAnimator on scale {
                        id: scaleAnimation
                        from: 1.0
                        to: 0.9
                        duration: 100
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }    
    }
}
