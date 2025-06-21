import QtQuick
import QtQuick.Controls
import Crescent.Core

TextField {
    id: textField
    property color accentColor: Theme.getColor("accent")
    property color baseLineColor: Theme.getColor("highContrast")
    property color errorColor: Theme.getColor("error")

    verticalAlignment: TextInput.AlignVCenter
    background: Item {
        
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 1
            color: baseLineColor
            Rectangle {
                id: focusLine
                anchors.centerIn: parent
                width: textField.activeFocus ? parent.width : 0
                height: 2
                color: accentColor
                opacity: textField.activeFocus ? 1 : 0

                Behavior on width {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 100 }
                }
            }

        }
    }

    color: Theme.getColor("textPrimary")
    font.pixelSize: 16
    padding: 0

    topPadding: 8
    bottomPadding: 8
}
