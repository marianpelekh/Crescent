import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Crescent.Theme

ListView {
    id: listView
    signal chatSelected(string chatId, string chatName)

    model: ListModel {
        ListElement { chatId: "1"; chatName: "Harry"; lastMessage: "Hello!" }
        ListElement { chatId: "2"; chatName: "Tom"; lastMessage: "Check this out!" }
        ListElement { chatId: "3"; chatName: "Emma"; lastMessage: "How are you doing?" }
    }

    property string activeChatId: ""

    delegate: ItemDelegate {
        id: delegateItem
        width: listView.width
        height: 70
        highlighted: listView.activeChatId === model.chatId

        background: Rectangle {
            color: delegateItem.down ? Theme.getColor("tertiary") :
            delegateItem.hovered ? Qt.rgba(Theme.getColor("tertiary").r,
            Theme.getColor("tertiary").g,
            Theme.getColor("tertiary").b, 0.7) :
            (delegateItem.highlighted ? Theme.getColor("tertiary") : "transparent")


            Rectangle {
                anchors.bottom: parent.bottom
                height: 3
                width: parent.width
                radius: 2
                color: listView.activeChatId === model.chatId 
                ? Theme.getColor("lightPrimary") 
                : delegateItem.down 
                ? Theme.getColor("lightPrimary")
                : delegateItem.hovered 
                ? Theme.getColor("border") 
                : Theme.getColor("primary")
            }
        }

        contentItem: RowLayout {
            spacing: 10
 
            Rectangle {
                width: 50
                height: 50
                border.width: 2 
                border.color: Theme.getColor("lightPrimary")
                radius: width / 2
                clip: true

                ShaderEffectSource {
                    id: avatarShader
                    sourceItem: avatar
                    hideSource: true
                    anchors.fill: parent
                }

                Image {
                    id: avatar
                    source: "qrc:/images/noimage.png"
                    width: parent.width
                    height: parent.height
                    fillMode: Image.PreserveAspectCrop
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                Label {
                    text: model.chatName
                    font.bold: true
                    font.pixelSize: 14
                    color: Theme.getColor("textPrimary")
                }

                Label {
                    text: model.lastMessage
                    font.pixelSize: 12
                    color: Theme.getColor("textSecondary")
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        onClicked: {
            listView.activeChatId = model.chatId;
            chatSelected(model.chatId, model.chatName);
        }
    }
}
