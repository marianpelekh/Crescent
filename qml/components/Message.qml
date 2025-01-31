import QtQuick
import QtQuick.Controls
import Crescent.Theme

Rectangle {
    id: root 

    property string sender
    property string text
    
    width: 200
    height: messageText.height + 10
    radius: 10
    color: Theme.getColor("messageSent")

    Column {
        anchors.verticalCenter: root.verticalCenter

        Text {
        id: messageText
        text: root.text
        color: Theme.getColor("textOnMessageSent")
        font.pixelSize: 14
    }
}
}

