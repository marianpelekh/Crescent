cmake_minimum_required(VERSION 3.21.1)

project(Crescent VERSION 0.0.1)

configure_file(CrescentConfig.h.in "${CMAKE_BINARY_DIR}/CrescentConfig.h")

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#for multimedia Qt Multimedia and for location there is Qt Location
find_package(Qt6 REQUIRED COMPONENTS Core)

