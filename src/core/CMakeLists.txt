qt_add_qml_module(core
    STATIC
    VERSION 1.0
    URI "Crescent.Core"
    SOURCES
        AuthManager.h
        RestAPIManager.h
        Theme.h 
        UserManager.h
        User.h
        MessageManager.h
        ChatManager.h
        Log.h
        AuthManager.cpp 
        RestAPIManager.cpp 
        Theme.cpp 
        UserManager.cpp
        MessageManager.cpp
        ChatManager.cpp
    RESOURCE_PREFIX /
)

target_link_libraries(core PRIVATE Qt6::Core Qt6::Gui Qt6Keychain::Qt6Keychain)
