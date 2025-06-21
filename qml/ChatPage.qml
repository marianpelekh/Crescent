import Crescent.Core
import Crescent.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: root

    property string chatId
    property string type
    property string chatName
    property string targetUserId
    property string objectName: "ChatPage"
    property bool isNewChat: false
    property var messageQueue: []

    function smoothScrollToBottom() {
        messageList.positionViewAtEnd();
        // scrollAnimation.to = Math.round(Math.max(0, messageList.contentHeight - messageList.height));
        // scrollAnimation.from = Math.round(messageList.contentY);
        // scrollAnimation.start();
        messageList.autoScroll = true;
    }

    function sendMessage() {
        const text = messageInput.text.trim();
        if (text.length === 0)
            return ;

        if (isNewChat) {
            // Додаємо повідомлення з тимчасовим статусом
            const tempId = "temp_" + Date.now();
            messageModel.addTempMessage(tempId, UserManager.username(), text);
            messageQueue.push({
                "id": tempId,
                "text": text
            });
            messageInput.text = "";
            if (messageQueue.length === 1) {
                ChatManager.createChat(targetUserId);
                chatCreationTimer.start();
            }
        } else {
            // Звичайна відправка
            messageModel.addMessage(UserManager.username(), text);
            messageInput.text = "";
        }
    }

    function processMessageQueue() {
        for (let i = 0; i < messageQueue.length; i++) {
            const msg = messageQueue[i];
            messageModel.updateMessageStatus(msg.id, "sent");
        }
        messageQueue = [];
    }

    function sendMessageInternal(text) {
        if (text.length > 0) {
            messageModel.addMessage(UserManager.username(), text);
            smoothScrollToBottom();
        }
    }

    onTargetUserIdChanged: {
        if (targetUserId && !chatId)
            isNewChat = true;

    }
    onChatIdChanged: {
        messageList.autoScroll = true;
        Qt.callLater(() => {
            smoothScrollToBottom();
        });
    }

    Timer {
        id: chatCreationTimer

        interval: 10000 // 10 секунд
        onTriggered: {
            if (isNewChat && messageQueue.length > 0) {
                errorPopup.text = "Чат не вдалося створити. Спробуйте ще раз.";
                errorPopup.open();
                messageQueue = [];
            }
        }
    }

    Connections {
        function onChatCreated(chatId) {
            if (isNewChat) {
                chatCreationTimer.stop();
                root.chatId = chatId;
                isNewChat = false;
                processMessageQueue();
            }
        }

        function onChatCreationFailed() {
            errorPopup.text = qsTr("Не вдалося створити чат");
            errorPopup.open();
            if (messageQueue.length > 0) {
                messageInput.text = messageQueue.join("\n");
                messageQueue = [];
            }
        }

        target: ChatManager
    }

    NumberAnimation {
        id: scrollAnimation

        target: messageList
        property: "contentY"
        duration: 300
        easing.type: Easing.InOutQuad
        onStarted: {
            to = Math.max(0, messageList.contentHeight - messageList.height);
        }
    }

    MessageModel {
        id: messageModel

        function addTempMessage(id, sender, text) {
            append({
                "id": id,
                "sender": sender,
                "text": text,
                "status": "pending",
                "created_at": Qt.formatTime(new Date(), "H:mm")
            });
        }

        function updateMessageStatus(id, status) {
            for (let i = 0; i < count; i++) {
                if (get(i).id === id) {
                    setProperty(i, "status", status);
                    break;
                }
            }
        }

        chatId: root.chatId
    }

    ColumnLayout {
        id: chatColumn

        anchors.fill: parent

        Rectangle {
            Layout.preferredHeight: chatLabel.height + 10
            Layout.fillWidth: true
            color: Theme.palette.tertiary
            z: 1

            Label {
                id: chatLabel

                text: root.chatName
                color: Theme.palette.textPrimary
                font.pixelSize: 16
                font.bold: true
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
            }

        }

        ListView {
            id: messageList

            property bool autoScroll: true

            Layout.margins: 10
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: messageModel
            onCountChanged: {
                if (autoScroll)
                    contentY = contentHeight;

            }
            // Detect user scroll and disable auto-follow
            onMovementStarted: {
                if (moving && contentY + height < contentHeight - 20)
                    autoScroll = false;

            }
            onMovementEnded: {
                autoScroll = (contentY + height >= contentHeight - 1);
            }
            Component.onCompleted: {
                smoothScrollToBottom();
            }
            onModelChanged: {
                messageList.positionViewAtEnd();
            }

            delegate: Message {
                sender: model.sender
                status: model.status
                created_at: model.created_at ? model.created_at : Qt.formatTime(new Date(), "H:mm")
                text: model.text
                onDeleteRequested: {
                    if (messageModel && typeof messageModel.removeMessage === "function")
                        messageModel.removeMessage(messageId);

                }
            }

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 45 > messageInput.implicitHeight + 5 ? 45 : messageInput.implicitHeight + 5 > chatColumn.height * 0.3 ? chatColumn.height * 0.3 : messageInput.implicitHeight + 5
            clip: true
            bottomLeftRadius: 10
            bottomRightRadius: 10
            color: Theme.palette.primary

            RowLayout {
                // MouseArea {
                //     Layout.preferredHeight: 22
                //     Layout.preferredWidth: 22
                //     Layout.leftMargin: 10
                //     Layout.rightMargin: 0
                //     cursorShape: Qt.PointingHandCursor
                //     onClicked: {
                //     }
                //     Text {
                //         id: includeButton
                //         font.family: iconFont.name
                //         text: "\ue900"
                //         color: Theme.palette.textSecondary
                //         font.pixelSize: 22
                //         renderType: Text.QtRendering
                //         antialiasing: true
                //         smooth: true
                //         layer.enabled: true
                //         layer.smooth: true
                //     }
                // }
                // MouseArea {
                //     Layout.preferredHeight: 22
                //     Layout.preferredWidth: 22
                //     Layout.leftMargin: 10
                //     Layout.rightMargin: 10
                //     cursorShape: Qt.PointingHandCursor
                //     onClicked: {
                //     }
                //     Text {
                //         id: emojiButton
                //         font.family: iconFont.name
                //         text: "\ue903"
                //         color: Theme.palette.textSecondary
                //         font.pixelSize: 22
                //         renderType: Text.QtRendering
                //         antialiasing: true
                //         smooth: true
                //         layer.enabled: true
                //         layer.smooth: true
                //     }
                // }

                anchors.fill: parent
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: {
                        let inputHeight = messageInput.contentHeight;
                        let maxHeight = chatColumn.height * 0.3;
                        return Math.min(Math.max(inputHeight, 40), maxHeight);
                    }
                    color: "transparent"
                    radius: 5

                    Flickable {
                        id: inputFlick

                        anchors.fill: parent
                        contentWidth: messageInput.paintedWidth
                        contentHeight: messageInput.paintedHeight
                        clip: true
                        interactive: messageInput.paintedHeight > height
                        boundsBehavior: Flickable.StopAtBounds
                        flickableDirection: Flickable.VerticalFlick

                        TextEdit {
                            id: messageInput

                            property string placeholder: "Type a message..."
                            // Додаємо властивість для обмеження
                            property int maxLength: 4096

                            width: inputFlick.width
                            height: Math.max(paintedHeight, 40)
                            color: Theme.palette.textPrimary
                            font.pixelSize: 14
                            leftPadding: 10
                            rightPadding: 10
                            wrapMode: TextEdit.Wrap
                            selectByMouse: true
                            focus: true
                            cursorVisible: true
                            // Обмеження довжини тексту
                            onTextChanged: {
                                if (length > maxLength) {
                                    // Обрізаємо зайві символи зі збереженням позиції курсора
                                    var cursorPos = cursorPosition;
                                    text = text.substring(0, maxLength);
                                    cursorPosition = Math.min(cursorPos, maxLength);
                                }
                                messagePlaceholder.visible = text.length === 0;
                            }
                            // Вертикальне центрування
                            topPadding: {
                                let space = height - contentHeight;
                                return space > 0 ? space / 2 : 0;
                            }
                            bottomPadding: topPadding
                            Keys.onReturnPressed: function(event) {
                                if (event.modifiers & Qt.ShiftModifier) {
                                    insert(cursorPosition, "\n");
                                } else if (text.length > 0) {
                                    console.log("Message sent:", text);
                                    sendMessage();
                                    smoothScrollToBottom();
                                }
                                event.accepted = true;
                            }

                            Label {
                                id: messagePlaceholder

                                text: messageInput.placeholder
                                color: Theme.palette.textDisabled
                                font.pixelSize: 14
                                anchors.fill: parent
                                verticalAlignment: Label.AlignVCenter
                                leftPadding: 10
                                visible: messageInput.text.length === 0
                            }

                        }

                    }

                }

                MouseArea {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    Layout.rightMargin: 10
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sendMessage();
                        console.log("Message sent:", messageInput.text);
                        scaleAnimation.start();
                        smoothScrollToBottom();
                    }

                    Text {
                        id: sendButton

                        font.family: iconFont.name
                        text: "\ue906"
                        color: Theme.palette.textPrimary
                        font.pixelSize: 28
                        renderType: Text.QtRendering
                        antialiasing: true
                        smooth: true
                        layer.enabled: true
                        layer.smooth: true
                    }

                    ScaleAnimator on scale {
                        id: scaleAnimation

                        from: 1
                        to: 0.9
                        duration: 100
                        easing.type: Easing.InOutQuad
                    }

                }

            }

        }

    }

    Item {
        id: scrollDownWrapper

        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        anchors.bottomMargin: 50
        height: scrollDown.height
        width: scrollDown.width
        visible: true
        opacity: scrollDown.visible ? 1 : 0
        y: scrollDown.visible ? 0 : 20

        Button {
            id: scrollDown

            height: 40
            width: height
            font.family: iconFont.name
            text: "\ue907"
            visible: messageList.contentY + messageList.height < messageList.contentHeight - 2
            onClicked: {
                smoothScrollToBottom();
            }

            background: Rectangle {
                radius: height / 2
                color: Theme.palette.background
                border.width: 1
                border.color: Theme.palette.border
            }

        }

        Binding {
            target: scrollDown
            property: "visible"
            value: messageList.contentY + messageList.height < messageList.contentHeight - 2
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }

        }

        Behavior on y {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }

        }

    }

}