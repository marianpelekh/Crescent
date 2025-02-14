import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Crescent.Theme
import Crescent.Models

Item {
    id: root 
    RowLayout {
        anchors.fill: parent
        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * (root.width < 700 ? 1.0 : 0.3)
            spacing: 10
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Log in")
                color: Theme.getColor("textPrimary")
            }
            TextField {
                id: loginField
                Layout.alignment: Qt.AlignHCenter
                placeholderText: qsTr("Login")
                color: Theme.getColor("textPrimary")
                background: Rectangle {
                    color: Theme.getColor("tertiary")
                    border.color: Theme.getColor("border")
                    border.width: 1
                    radius: 5
                }
            }

            TextField {
                id: passwordField
                Layout.alignment: Qt.AlignHCenter
                placeholderText: qsTr("Password")
                echoMode: TextInput.Password   
                color: Theme.getColor("textPrimary")
                background: Rectangle {
                    color: Theme.getColor("tertiary")
                    border.color: Theme.getColor("border")
                    border.width: 1
                    radius: 5
                }
            }

            Button {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Enter")
                contentItem: Text {
                    text: qsTr("Enter")
                    color: Theme.getColor("textPrimary")
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: Theme.getColor("accent")
                    radius: 5
                }
                Layout.preferredWidth: 120
                Layout.preferredHeight: 30
            } 
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.7
            color: Theme.getColor("secondary")
            visible: root.width >= 700

            Image {
                anchors.centerIn: parent
                anchors.fill: parent
                source: "qrc:/images/login.png"
                fillMode: Image.PreserveAspectCrop
            }

        }
    }
}
