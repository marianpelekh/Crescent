import Crescent.Core
import Crescent.Models
import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Effects
import QtQuick.Layouts

ColumnLayout {
    // Layout.preferredWidth: parent.width * 0.25
    // Layout.minimumWidth: parent.width * 0.2
    // Layout.maximumWidth: parent.width * 0.3

    signal chatSelected(string chatId, string chatName)

    spacing: 0
    Layout.fillWidth: true
    Layout.fillHeight: true

    TextField {
        id: searchField

        Layout.fillWidth: true
        Layout.margins: 5
        placeholderText: qsTr("Search chats...")
        color: Theme.palette.textSecondary
        height: 40
        onTextChanged: {
            debounceTimer.restart();
        }

        background: Rectangle {
            radius: 8
            color: Theme.palette.background
            border.color: Theme.palette.border
        }

    }

    Timer {
        id: debounceTimer

        interval: 400
        repeat: false
        onTriggered: {
            if (searchField.text.length > 1)
                chatsListModel.searchChats(searchField.text);
            else
                chatsListModel.clearSearch(); // повертаємо основний список
        }
    }

    ListView {
        id: chatsListView

        property string activeChatId: ""

        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        Component.onCompleted: {
            console.log("Model count:", model.count);
            console.log("Calling loadChats...");
            model.loadChats();
        }

        Connections {
            function onCountChanged() {
                console.log("Model count changed:", chatsListModel.count);
                chatsListView.positionViewAtBeginning();
            }

            target: chatsListModel
        }

        model: ChatListModel {
            id: chatsListModel
        }

        delegate: ItemDelegate {
            id: delegateItem

            Component.onCompleted: {
                console.log("Delegate loaded: id=" + model.chatId + ", name=" + model.chatName);
            }
            width: chatsListView.width
            height: 70
            highlighted: chatsListView.activeChatId === model.chatId
            onClicked: {
                chatsListView.activeChatId = model.chatId;
                chatSelected(model.chatId, model.chatName);
            }

            background: Rectangle {
                topLeftRadius: 8
                topRightRadius: 8
                color: delegateItem.down ? 
                    Theme.palette.tertiary : 
                    delegateItem.hovered ? 
                        Qt.rgba(Theme.palette.tertiary.r, Theme.palette.tertiary.g, Theme.palette.tertiary.b, 0.7) : 
                        (delegateItem.highlighted ? Theme.palette.tertiary : "transparent")

                Rectangle {
                    anchors.bottom: parent.bottom
                    height: 3
                    width: parent.width
                    radius: 2
                    color: chatsListView.activeChatId === model.chatId ? 
                        Theme.palette.chatsSeparatorDown : 
                        delegateItem.down ? 
                            Theme.palette.chatsSeparatorDown : 
                            delegateItem.hovered ? 
                                Theme.palette.chatsSeparatorHovered : 
                                Theme.palette.chatsSeparator
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                }

            }

            contentItem: RowLayout {
                spacing: 10

                Rectangle {
                    width: 54
                    height: 54
                    radius: width / 2
                    color: "transparent"
                    border.color: "black"
                    border.width: 2

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: width / 2
                        color: Theme.palette.highContrast
                        clip: true

                        Image {
                            id: avatar

                            source: model.chatImage
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: width
                            sourceSize.height: height
                            anchors.centerIn: parent
                            anchors.fill: parent
                            smooth: true
                            visible: false
                        }

                        MultiEffect {
                            source: avatar
                            anchors.fill: avatar
                            maskEnabled: true
                            maskSource: maska
                        }

                        Item {
                            id: maska

                            width: avatar.width
                            height: avatar.height
                            layer.enabled: true
                            visible: false

                            Rectangle {
                                width: avatar.width
                                height: avatar.height
                                radius: width / 2
                                color: "black"
                            }

                        }

                    }

                }

                ColumnLayout {
                    // Label {
                    //     text: model.lastMessage
                    //     font.pixelSize: 12
                    //     color: Theme.palette.textSecondary
                    //     elide: Text.ElideRight
                    //     Layout.fillWidth: true
                    // }

                    Layout.fillWidth: true

                    Label {
                        text: model.chatName
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignLeft
                        font.bold: true
                        font.pixelSize: 14
                        color: Theme.palette.textPrimary
                    }

                }

            }

        }

    }

    Item {
        visible: chatsListView.count == 0
        anchors.centerIn: parent
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Text {
            id: pulseIcon

            font.family: iconFont.name
            text: "\ue901"
            renderType: Text.QtRendering
            antialiasing: true
            layer.enabled: true
            layer.smooth: true
            color: Theme.palette.highContrast
            font.pixelSize: 30
            anchors.centerIn: parent
            // Для векторного вигляду використовуємо техніку згладжування
            layer.textureSize: Qt.size(width * 2, height * 2)
            transformOrigin: Item.Center

            // Послідовна анімація з двома фазами
            SequentialAnimation on scale {
                id: pulseAnimation

                loops: Animation.Infinite
                running: true

                // Фаза збільшення
                NumberAnimation {
                    from: 1
                    to: 1.5
                    duration: 500
                    easing.type: Easing.InOutQuad
                }

                // Фаза зменшення
                NumberAnimation {
                    from: 1.5
                    to: 1
                    duration: 500
                    easing.type: Easing.InOutQuad
                }

            }

        }

    }

    Rectangle {
        id: footer

        Layout.fillWidth: true
        height: 60
        color: "transparent"

        Text {
            anchors.centerIn: parent
            width: parent.width - 20
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: chatsListModel.count === 0 ? qsTr("You have no chats") : qsTr("Search for users by their username to add chats")
            color: Theme.palette.textSecondary
            font.pixelSize: 12
        }

    }

}