import QtQuick
import QtQuick.Layouts
import Crescent.Theme

Item {
    id: root 
    property string sender
    property string text
    property bool isSender: sender === "You"

    width: parent.width
    height: message.height + 10 

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
            color: Theme.getColor("checkMarkReceivedBg")
            visible: !root.isSender
            Layout.rightMargin: -8
            Layout.alignment: message.height > 100 ? Qt.AlignBottom : Qt.AlignVCenter
            Layout.bottomMargin: message.height > 100 ? 15 : 0

            Text {
                font.family: iconFont.name
                text: "\ue907"
                color: Theme.getColor("checkMarkReceived")
                anchors.centerIn: parent
                font.pixelSize: 8
            }
        }

        Rectangle {
            id: message
            Layout.preferredWidth: Math.min(messageLayout.implicitWidth + 20, root.width * 0.75)
            Layout.preferredHeight: messageLayout.implicitHeight + 10
            radius: 10
            color: root.isSender ? null : Theme.getColor("messageReceived")
            Component.onCompleted: {
                if (!root.isSender) {
                    message.gradient = undefined; 
                }
            }

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Theme.getColor("messageSentPrimary") } 
                GradientStop { position: 1.0; color: Theme.getColor("messageSentSecondary") }
            }  
            Layout.alignment: root.isSender ? Qt.AlignRight : Qt.AlignLeft

            ColumnLayout {
                id: messageLayout
                anchors.centerIn: parent

                Text {
                    id: messageText
                    text: root.text
                    font.pixelSize: 14
                    color: root.isSender ? Theme.getColor("textOnMessageSent") : Theme.getColor("textOnMessageReceived")
                    Layout.maximumWidth: message.width - 20
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideNone
                    textFormat: Text.PlainText
                    Layout.fillWidth: true
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5
                }

                Text {
                    id: messageHour
                    text: Qt.formatTime(new Date(), "H:mm")
                    Layout.alignment: Text.AlignRight
                    Layout.rightMargin: 5
                    font.pixelSize: 8 
                    color: root.isSender ? Theme.getColor("timeOnMessageSent") : Theme.getColor("timeOnMessageReceived")
                }
            }
        } 

        Rectangle {
            id: rightCheckMark
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            radius: 8
            z: 5
            color: Theme.getColor("checkMarkSentBg")
            visible: root.isSender
            Layout.leftMargin: -8
            Layout.alignment: message.height > 100 ? Qt.AlignBottom : Qt.AlignVCenter
            Layout.bottomMargin: message.height > 100 ? 15 : 0

            Text {
                font.family: iconFont.name
                text: "\ue907"
                color: Theme.getColor("checkMarkSent")
                anchors.centerIn: parent
                font.pixelSize: 8
            }
        }

        Item {
            Layout.fillWidth: !root.isSender
        }
    }
}
