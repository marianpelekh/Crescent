qt_add_qml_module(models_cpp
    STATIC
    VERSION 1.0
    URI "Crescent.Models"
    SOURCES
        ChatModel.h 
        MessageModel.h
        ChatModel.cpp 
        MessageModel.cpp
        ChatListModel.h
        ChatListModel.cpp
    RESOURCE_PREFIX /qt/qml
)

target_link_libraries(models_cpp PRIVATE Qt6::Core Qt6::Gui)