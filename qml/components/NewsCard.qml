import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Crescent.Theme 1.0

Rectangle {
    id: root
    
    property string title
    property string description

    width: parent.width
    height: 120
    color: "transparent"
    radius: 10

    Row {
        anchors.fill: parent
        spacing: 10 

        RoundedImage {
            width: 210
            height: 120
            source: "qrc:/images/noimage.png"
            fillMode: Image.PreserveAspectFit
            radius: 10
            mipmap: true
        }

        Column {
            width: parent.width - 210;
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: root.title
                font.bold: true
                font.pixelSize: 18
                color: Theme.getColor("textPrimary")
            }

            Text {
                text: root.description
                font.pixelSize: 14
                color: Theme.getColor("textSecondary")
                wrapMode: Text.Wrap
            }
        }
    }
}

