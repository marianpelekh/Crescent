import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Crescent.Theme
import "../components"
Item {
    Rectangle {
        anchors.fill: parent
        color: Theme.getColor("secondary")
        bottomRightRadius: 10
        bottomLeftRadius: 10
        clip: true
        ColumnLayout {
            anchors.fill: parent
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Welcome to Crescent!\n\nThis is alpha version of new\ncrossplatform secured messanger!\nGet a try!"
                    font.pixelSize: 24
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            NewsCard {
                title: "Patch 0.1.0"
                description: "New features added..."
            }


            Rectangle {
                Layout.alignment: Qt.AlignBottom
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                bottomRightRadius: 10
                bottomLeftRadius: 10
                clip: true
                color: Theme.getColor("primary")
            }
        }
    }
}
