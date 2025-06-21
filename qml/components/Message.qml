import Crescent.Core
import QtQuick 2.15
import QtQuick.Layouts

Item {
    id: root

    property string messageId
    property string sender
    property string text
    property string status
    property string created_at
    property bool isSender: sender === UserManager.username()

    signal deleteRequested(string messageId)

    width: parent ? parent.width : 100
    height: message.height + 10

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: contextMenu.popup()
        onPressAndHold: contextMenu.popup() // Для сенсорних екранів
    }

    CrescentMenu {
        id: contextMenu

        TextInput {
            id: hiddenCopyField

            visible: false
            width: 0
            height: 0
        }

        CrescentMenuItem {
            text: qsTr("Copy")
            onTriggered: {
                onTriggered:
                {
                    // Записуємо текст у приховане поле
                    hiddenCopyField.text = root.text;
                    // Виділяємо весь текст
                    hiddenCopyField.selectAll();
                    // Копіюємо виділений текст
                    hiddenCopyField.copy();
                    console.log("Текст скопійовано");
                };
            }
        }

        // Пункт меню для видалення (тільки для своїх повідомлень)
        CrescentMenuItem {
            text: qsTr("Delete")
            visible: root.isSender
            onTriggered: root.deleteRequested(root.messageId)
        }

    }

    RowLayout {
        id: rowLayout

        spacing: 0
        width: parent.width

        Item {
            Layout.fillWidth: root.isSender
        }

        Rectangle {
            id: leftCheckMark

            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            radius: 8
            z: 5
            color: Theme.palette.checkMarkReceivedBg
            visible: !root.isSender
            Layout.rightMargin: -8
            Layout.alignment: message.height > 100 ? Qt.AlignBottom : Qt.AlignVCenter
            Layout.bottomMargin: message.height > 100 ? 15 : 0

            Text {
                font.family: iconFont.name
                text: "\ue907"
                color: Theme.palette.checkMarkReceived
                anchors.centerIn: parent
                font.pixelSize: 8
            }

        }

        Rectangle {
            id: message

            Layout.preferredWidth: Math.min(messageLayout.implicitWidth + 20, root.width * 0.75)
            Layout.preferredHeight: messageLayout.implicitHeight + 10
            radius: 10
            color: root.isSender ? null : Theme.palette.messageReceived
            Component.onCompleted: {
                if (!root.isSender)
                    message.gradient = undefined;

            }
            Layout.alignment: root.isSender ? Qt.AlignRight : Qt.AlignLeft

            ColumnLayout {
                id: messageLayout

                anchors.centerIn: parent

                Text {
                    id: senderName

                    font.pixelSize: 12
                    color: root.isSender ? Theme.palette.textOnMessageSent : Theme.palette.textOnMessageReceived
                    Layout.maximumWidth: message.width - 20
                    font.bold: true
                    text: root.sender
                }

                // Text {
                //     id: messageText
                //
                //     text: root.text
                //     font.pixelSize: 14
                //     color: root.isSender ? Theme.palette.textOnMessageSent : Theme.palette.textOnMessageReceived
                //     Layout.maximumWidth: message.width - 20
                //     wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                //     elide: Text.ElideNone
                //     textFormat: Text.PlainText
                //     Layout.fillWidth: true
                //     Layout.leftMargin: 5
                //     Layout.rightMargin: 5
                // }
                TextEdit {
    id: messageText

    text: root.text
    font.pixelSize: 14
    color: root.isSender ? Theme.palette.textOnMessageSent : Theme.palette.textOnMessageReceived
    Layout.maximumWidth: message.width - 20
    wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
    textFormat: TextEdit.PlainText
    Layout.fillWidth: true
    Layout.leftMargin: 5
    Layout.rightMargin: 5

    // Дозволяємо вибір, але заборонити редагування
    readOnly: true
    selectByMouse: true
    cursorVisible: false // Сховати курсор у стані спокою

    // Додаткові налаштування для зручності
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor // Змінити курсор при наведенні
        acceptedButtons: Qt.NoButton // Не блокуємо кліки
        hoverEnabled: true
    }
}


                Text {
                    id: messageHour

                    text: Qt.formatTime(new Date(root.created_at), "H:mm")
                    Layout.alignment: Text.AlignRight
                    Layout.rightMargin: 5
                    font.pixelSize: 8
                    color: root.isSender ? Theme.palette.timeOnMessageSent : Theme.palette.timeOnMessageReceived
                }

            }

            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop {
                    position: 0
                    color: Theme.palette.messageSentPrimary
                }

                GradientStop {
                    position: 1
                    color: Theme.palette.messageSentSecondary
                }

            }

        }

        Rectangle {
            id: rightCheckMark

            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            radius: 8
            z: 5
            color: Theme.palette.checkMarkSentBg
            visible: root.isSender
            Layout.leftMargin: -8
            Layout.alignment: message.height > 100 ? Qt.AlignBottom : Qt.AlignVCenter
            Layout.bottomMargin: message.height > 100 ? 15 : 0

            Text {
                font.family: iconFont.name
                text: root.status === "sent" ? "\ue907" : "\ue907"
                color: Theme.palette.checkMarkSent
                anchors.centerIn: parent
                font.pixelSize: 8
            }

        }

        Item {
            Layout.fillWidth: !root.isSender
        }

    }

}