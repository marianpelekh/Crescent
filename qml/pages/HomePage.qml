import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts

Item {
    ColumnLayout {
        anchors.fill: parent

        Label {
            text: "Welcome to Crescent!"
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        NewsCard {
            title: "Patch 0.1.0"
            description: "New features added..."
        }
    }
}
