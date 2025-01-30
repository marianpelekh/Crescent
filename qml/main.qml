import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls 2.15


ApplicationWindow {
    id: root
    visible: true
    title: "Crescent"
    
    header: ToolBar {
        height: 40
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        id: header
        contentItem: Rectangle {
            anchors.fill: parent
            RowLayout {
                anchors.fill: parent
                spacing: 10

                Image {
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    fillMode: Image.PreserveAspectFit
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignLeft
                }
            }
        }
    }

    width: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? Screen.width : Screen.width * 0.75
    height: (Qt.platform.os === "android" || Qt.platform.os === "ios") ? Screen.height : Screen.height * 0.75
}
