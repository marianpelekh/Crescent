# add_subdirectory(components)

qt_add_qml_module(main
    STATIC
    VERSION 1.0
    URI "Crescent.Main"
    QML_FILES
        main.qml
        AuthPage.qml
        ChatPage.qml
        HomePage.qml
        components/ChatsList.qml 
        components/Message.qml 
        components/NewsCard.qml 
        components/RoundedImage.qml 
        components/FormTextField.qml
        components/CrescentMenu.qml
        components/CrescentMenuItem.qml
    RESOURCE_PREFIX /
)

target_link_libraries(main PRIVATE coreplugin models_cppplugin)
