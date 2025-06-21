cmake_minimum_required(VERSION 3.12 FATAL_ERROR)
set(CMAKE_BUILD_TYPE Debug)

set(PROJECT_NAME Crescent)

#set(CMAKE_BUILD_TYPE "Debug")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
#set(CMAKE_CXX_COMPILER "clang++")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")

set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOMOC ON)
set(QT_QML_GENERATE_QMLLS_INI ON)
set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml)

project(${PROJECT_NAME} VERSION 0.1 LANGUAGES CXX)

find_package(Qt6 COMPONENTS Core Gui Qml QuickControls2 WebSockets REQUIRED)
find_package(Qt6Keychain REQUIRED)

include_directories(src)
include_directories(qml)

qt_add_executable(${PROJECT_NAME}
    src/main.cpp 
    # src/core/Theme.cpp
    # src/core/AuthManager.cpp
    # src/core/RestAPIManager.cpp
    # src/models/MessageModel.cpp
    # qml/QmlResources.qrc
    resources/Resources.qrc
    # src/core/Log.h
)

add_subdirectory(src)
add_subdirectory(qml)

set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY
    QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_SOURCE_DIR}/android
)

set_target_properties(${PROJECT_NAME} PROPERTIES WIN32_EXECUTABLE TRUE)

target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::QuickControls2 Qt6::WebSockets Qt6Keychain::Qt6Keychain mainplugin coreplugin models_cppplugin)

configure_file(qmlls.ini.in ${CMAKE_SOURCE_DIR}/.qmlls.ini) 
# add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
#     COMMAND ${CMAKE_COMMAND} -E copy_directory
#     ${CMAKE_SOURCE_DIR}/resources/themes ${CMAKE_BINARY_DIR}/bin/themes)

