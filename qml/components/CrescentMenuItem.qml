import Crescent.Core
import Crescent.Main
import QtQuick
import QtQuick.Controls

MenuItem {
    id: menuItem
    property bool hasSubMenu
    property Menu childMenu

    implicitHeight: 40
    // onHoveredChanged: {
    //     if (hovered && childMenu && hasSubMenu)
    //         childMenu.open();
    //     else if (hovered && hasSubMenu)
    //         console.log("SubMenu not found");
        
    // }
    onClicked: childMenu.open()

    Rectangle {
        id: separator

        // Fixed: Access parent menu through delegate context
        visible: typeof index !== 'undefined' && index < (menuItem.menu.items.length - 1)
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Theme.palette.chatsSeparator
    }

    background: Rectangle {
        color: menuItem.highlighted ? Theme.palette.chatsSeparatorHovered : "transparent"
        radius: 2
    }

    contentItem: Text {
        text: menuItem.text
        color: Theme.palette.textPrimary
        font.pixelSize: 14
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        leftPadding: 15
    }

    indicator: Item {
        visible: menuItem.childMenu !== null
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 20
        height: 20

        // Image {
        //     source: "qrc:/logos/crescent_short.svg"
        //     anchors.centerIn: parent
        //     width: 12
        //     height: 12
        //     sourceSize: Qt.size(12, 12)
        // }

    }

}
