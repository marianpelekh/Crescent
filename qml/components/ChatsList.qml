import QtQuick
import QtQuick.Controls 2.15

ListView {
    id: listView
    signal chatSelected(string chatId)

    model: ListModel {
        ListElement { chatId: "1"; name: "Harry"; lastMessage: "Hello!" }
        ListElement { chatId: "2"; name: "Tom"; lastMessage: "Check this out!" }
    }

    delegate: ItemDelegate {
        width: listView.width
        text: model.name
        onClicked: chatSelected(model.chatId)
    }
}
