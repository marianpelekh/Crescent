import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
// import QtQuick.Controls.IOS
import QtQuick.Layouts
import Crescent.Core
import Crescent.Main
// import Crescent.Components

Item {
    id: root
    property bool isSignUp: false
    RowLayout {
        anchors.fill: parent
        spacing: 0
        clip: true

        Item {
            id: formContainer
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * (root.width < 700 ? 1.0 : 0.3)
            clip: true

            ColumnLayout {
                id: signinForm
                anchors.fill: parent
                spacing: 10
                opacity: root.isSignUp ? 0 : 1
                enabled: opacity > 0

                Behavior on opacity {
                    NumberAnimation { duration: 300 }
                }

                Item { Layout.fillHeight: true }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Sign in")
                    font.pixelSize: 24
                    font.bold: true
                    color: Theme.palette.textPrimary
                }
                FormTextField {
                    id: usernameSignInField
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 200
                    placeholderText: "Username"
                    placeholderTextColor: Theme.palette.textPrimary
                }
                FormTextField {
                    id: passwordSignInField
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 200
                    echoMode: TextInput.Password
                    placeholderText: "Password"
                    placeholderTextColor: Theme.palette.textPrimary
                }
                // TextField {
                //     Layout.alignment: Qt.AlignHCenter
                //     Layout.preferredWidth: 200
                //     Layout.preferredHeight: 35
                //     placeholderText: qsTr("Login")
                //     color: Theme.palette.textPrimary
                //     Material.accent: Theme.palette.border
                //     Material.background: Theme.palette.highContrast
                //     background: Rectangle {
                //         color: Theme.palette.tertiary
                //         border { color: Theme.palette.border; width: 1 }
                //         radius: 5
                //     }
                // }

                // TextField {
                //     id: passwordSignInField
                //     Layout.alignment: Qt.AlignHCenter
                //     Layout.preferredWidth: 200
                //     Layout.preferredHeight: 35
                //     placeholderText: qsTr("Password")
                //     echoMode: TextInput.Password
                //     color: Theme.palette.textPrimary
                //     // background: Rectangle {
                //     //     color: Theme.palette.tertiary
                //     //     border { color: Theme.palette.border; width: 1 }
                //     //     radius: 5
                //     // }
                // }

                Button {
                    id: enterButton
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 45 
                    Material.elevation: 2
                    background: Rectangle {
                        id: btnBg1
                        color: Theme.palette.accent
                        radius: 5
                    }
                    contentItem: Text {
                        text: qsTr("Sign in")
                        color: Theme.palette.accentButtonText
                        font { bold: true; pixelSize: 16 }
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: btnBg1.color = Theme.palette.accentDark
                        onReleased: {
                            btnBg1.color = Theme.palette.accent
                            enterButton.clicked()
                        }
                    }
                    onClicked: { 
                        AuthManager.signInUser(usernameSignInField.text, passwordSignInField.text);
                    }
                } 

                Keys.onReturnPressed: {
                    AuthManager.signInUser(usernameSignInField.text, passwordSignInField.text);
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Sign up")
                    color: Theme.palette.textPrimary
                    font.pixelSize: 12
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.isSignUp = true
                    }
                }

                Item { Layout.fillHeight: true }
            }

            ColumnLayout {
                id: signupForm
                anchors.fill: parent
                spacing: 10
                opacity: root.isSignUp ? 1 : 0
                enabled: opacity > 0

                Behavior on opacity {
                    NumberAnimation { duration: 300 }
                }

                Item { Layout.fillHeight: true }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Sign up")
                    font.pixelSize: 24
                    font.bold: true
                    color: Theme.palette.textPrimary
                }

                FormTextField {
                    id: emailSignUpField
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 35
                    placeholderText: qsTr("Email")
                    placeholderTextColor: Theme.palette.textPrimary

                    property bool showError: false
                    validator: RegularExpressionValidator {
                        regularExpression: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
                    }

                    // background: Rectangle {
                    //     border {
                    //         color: emailSignUpField.showError ? 
                    //         Theme.palette.errorBorder : 
                    //         Color("transparent")
                    //     }
                    //     radius: 5
                    // }
                    
                    onTextChanged: {
                        showError = text.length > 0 && !acceptableInput
                    }
                }

                Text {
                    id: emailError
                    visible: emailSignUpField.showError
                    text: qsTr("Invalid email format")
                    color: Theme.palette.errorText
                    font.pixelSize: 10
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: -5

                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }
                FormTextField {
                    id: usernameSignUpField
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 35
                    placeholderText: qsTr("Username")
                    placeholderTextColor: Theme.palette.textPrimary
                }

                FormTextField {
                    id: nameSignUpField
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 35
                    placeholderText: qsTr("Name")
                    placeholderTextColor: Theme.palette.textPrimary
                }

                FormTextField {
                    id: passwordSignUpField
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 35
                    placeholderText: qsTr("Password")
                    placeholderTextColor: Theme.palette.textPrimary
                    echoMode: TextInput.Password
                }

                FormTextField {
                    id: confirmPasswordSignUpField
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 35
                    placeholderText: qsTr("Confirm Password")
                    placeholderTextColor: Theme.palette.textPrimary
                    echoMode: TextInput.Password
                }

                Button {
                    id: createAccountBtn
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 45  
                    Material.elevation: 2
                    background: Rectangle {
                        id: btnBg2
                        color: Theme.palette.accent
                        radius: 5
                    }
                    contentItem: Text {
                        text: qsTr("Create Account")
                        color: Theme.palette.accentButtonText
                        font { bold: true; pixelSize: 16 }
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: btnBg2.color = Theme.palette.accentDark
                        onReleased: {
                            btnBg2.color = Theme.palette.accent
                            createAccountBtn.clicked()
                        }
                    }
                    onClicked: {
                        if (passwordSignUpField.text == confirmPasswordSignUpField.text) {
                            AuthManager.signUpUser(emailSignUpField.text, usernameSignUpField.text, nameSignUpField.text, passwordSignUpField.text); 
                        } else {
                            AuthManager.authError("Password and it's confirmation do not match.");
                        }
                    }
                } 

                Keys.onReturnPressed: {
                    if (passwordSignUpField.text == confirmPasswordSignUpField.text) {
                        console.log(passwordSignUpField.text, confirmPasswordSignUpField.text);
                        AuthManager.signUpUser(emailSignUpField.text, usernameSignUpField.text, nameSignUpField.text, passwordSignUpField.text); 
                    } else {
                        AuthManager.authError("Password and it's confirmation do not match.");
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Back to Sign in")
                    color: Theme.palette.textPrimary
                    font.pixelSize: 12
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.isSignUp = false
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        // Right image panel
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            visible: root.width >= 700
            color: Theme.palette.secondary

            Image {
                anchors.fill: parent
                source: "qrc:/images/login.png"
                fillMode: Image.PreserveAspectCrop
            }

            Text {
                anchors.centerIn: parent
                width: parent.width * 0.8
                text: qsTr("Crescent – a new secured messenger!")
                color: Theme.palette.loginImageText
                font { pixelSize: 48; bold: true }
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                z: 1
            }
        }
    }
}