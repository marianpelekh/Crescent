qt_add_qml_module(components
    STATIC
    VERSION 1.0
    URI "Crescent.Components"
    QML_FILES
        ChatsList.qml 
        FormTextField.qml 
        Message.qml 
        NewsCard.qml 
        RoundedImage.qml 
        CrescentMenu.qml
        CrescentMenuItem.qml
    RESOURCE_PREFIX /
)

target_link_libraries(components PRIVATE coreplugin )
