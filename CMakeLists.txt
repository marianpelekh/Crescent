cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

set(PROJECT_NAME Crescent)

set(CMAKE_BUILD_TYPE "Debug")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_COMPILER "clang++")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")

set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOMOC ON)

project(${PROJECT_NAME} VERSION 0.1 LANGUAGES CXX)

find_package(Qt6 COMPONENTS Core Widgets Gui Qml Quick QuickControls2 WebSockets REQUIRED)

include_directories(src)
include_directories(qml)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

add_executable(${PROJECT_NAME}
    src/main.cpp 
    src/core/Theme.cpp
    # src/core/LoginUser.cpp
    src/core/NetworkManager.cpp
    src/models/MessageModel.cpp
    qml/QmlResources.qrc 
    resources/Resources.qrc 
)

target_link_libraries(${PROJECT_NAME} Qt6::Core Qt6::Widgets Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::WebSockets)

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${CMAKE_SOURCE_DIR}/resources/themes ${CMAKE_BINARY_DIR}/bin/themes)

