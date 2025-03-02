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
                font.pixelSize: 24
                font.bold: true
                color: Theme.getColor("textPrimary")
            }
            TextField {
                id: loginField
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 35
                Layout.preferredWidth: 200
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
                Layout.preferredHeight: 35
                Layout.preferredWidth: 200
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
                id: enterButton
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Enter")
                contentItem: Text {
                    text: qsTr("Enter")
                    font.bold: true
                    color: Theme.getColor("accentButtonText")
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    id: buttonBackground
                    color: Theme.getColor("accent")
                    radius: 5
                }
                Layout.preferredWidth: 200
                Layout.preferredHeight: 30

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onPressed: {
                        buttonBackground.color = Theme.getColor("accentDark");
                    }

                    onReleased: {
                        buttonBackground.color = Theme.getColor("accent");
                        enterButton.clicked()
                    }
                }

                onClicked: { 
                    networkManager.loginUser(loginField.text, passwordField.text);
                }
            } 

            Keys.onReturnPressed: {
                networkManager.loginUser(loginField.text, passwordField.text);
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

            Text {
                anchors.centerIn: parent
                color: Theme.getColor("loginImageText")
                font.pixelSize: 48
                font.bold: true
                text: qsTr("Crescent – a new secured messenger!")
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                width: parent.width * 0.8
                z: 1
            }
        }
    }
}
