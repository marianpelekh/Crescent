import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Crescent.Theme 1.0

Rectangle {
    width: parent.width
    height: 120
    color: "transparent"
    radius: 10

    Row {
        anchors.fill: parent
        spacing: 10 

        Image {
            width: 210
            height: 120
            source: "qrc:/images/base_image.png"
            fillMode: Image.PreserveAspectCrop
        }

        Column {
            width: parent.width - 210;
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: "Patch 0.1:Alpha"
                font.bold: true
                font.pixelSize: 18
                color: Theme.getColor("textPrimary")
            }

            Text {
                text: "First patch of Crescent. Stay tuned."
                font.pixelSize: 14
                color: Theme.getColor("textSecondary")
                wrapMode: Text.Wrap
            }
        }
    }
}

