import Crescent.Core
import Crescent.Main
import QtQuick
import QtQuick.Controls

Menu {
    id: rootMenu

    // Основні налаштування меню
    implicitWidth: 200
    padding: 4
    onActiveFocusChanged: {
        if (!activeFocus) {
            close();
        }
    }

    // Фон меню
    background: Rectangle {
        color: Theme.palette.primary
        radius: 4
        border.width: 1
        border.color: Theme.palette.border
    }

    // Кастомний делегат для всіх пунктів меню
    delegate: CrescentMenuItem {
    }

}
