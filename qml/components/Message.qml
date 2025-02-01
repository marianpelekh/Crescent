import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Crescent.Theme

Item {
    id: root 

    property string sender
    property string text

    width: parent.width
    height: message.height + 10 

    RowLayout {
        width: parent.width 
        spacing: 10
        anchors.right: root.right
        anchors.left: root.left
        Rectangle {
            id: message
            Layout.preferredWidth: Math.min(messageText.implicitWidth + 20, parent.width * 0.75)
            Layout.preferredHeight: messageText.implicitHeight + 10
            radius: 10
            bottomLeftRadius: sender === "You" ? 10 : 0 
            bottomRightRadius: sender === "You" ? 0 : 10

            color: sender === "You" ? Theme.getColor("messageSent") : Theme.getColor("messageReceived")
            Layout.alignment: sender === "You" ? Qt.AlignRight : Qt.AlignLeft
            
            Text {
                id: messageText
                text: root.text
                font.pixelSize: 14
                anchors.centerIn: parent
                color: sender === "You" ? Theme.getColor("textOnMessageSent") : Theme.getColor("textOnMessageReceived")
                anchors.margins: 5
                wrapMode: Text.Wrap
                width: parent.width - 10
            }
        }
    }
}
