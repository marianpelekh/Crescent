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
        Flickable {
            id: flickable
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: bottomBar.top
            contentHeight: columnLayout.implicitHeight
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            anchors.margins: 20
            anchors.bottomMargin: 0

            ColumnLayout {
                id: columnLayout
                width: parent.width

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "Welcome to Crescent!\n\nThis is alpha version of new\ncrossplatform secured messanger!\nGet a try!"
                        color: Theme.getColor("textPrimary")
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                Repeater {
                    model: 6
                    delegate: NewsCard {
                        title: "Patch 0.1.0"
                        description: "New features added..."
                    }
                }

            }
        }
        Rectangle {
            id: bottomBar
            height: 40
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            bottomRightRadius: 10
            bottomLeftRadius: 10
            clip: true
            color: Theme.getColor("primary")
        }

    }
}
