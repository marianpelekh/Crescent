import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Crescent.Core

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
            source: "qrc:/images/common.png"
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

