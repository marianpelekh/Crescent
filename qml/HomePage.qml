import Crescent.Core
import Crescent.Main
import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Effects
import QtQuick.Layouts

Item {
    Rectangle {
        anchors.fill: parent
        bottomRightRadius: 10
        bottomLeftRadius: 10
        clip: true

        Image {
            id: backgroundImage
            anchors.fill: parent
            source: "qrc:/images/login.png"
            fillMode: Image.PreserveAspectCrop
            visible: false
        }

        MultiEffect {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height - 10
            source: backgroundImage
            blurEnabled: true
            blur: 1
            shadowEnabled: false
            opacity: 1
        }

        Flickable {
            id: flickable
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
                bottom: bottomBar.top
                margins: 20
                bottomMargin: 0
            }
            contentHeight: parent.height - 40
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            Item {
                anchors.fill: parent

                Label {
                    text: qsTr("Welcome to Crescent!\n\nThis is your new\ncrossplatform secured messanger!\nGive it a try!")
                    color: Theme.palette.loginImageText
                    font {
                        pixelSize: 32
                        bold: true
                    }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    anchors.centerIn: parent
                    width: parent.width * 0.8
                }
            }
        }

        Rectangle {
            id: bottomBar
            height: 40
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            bottomRightRadius: 10
            bottomLeftRadius: 10
            clip: true
            color: Theme.palette.primary
        }
    }
}