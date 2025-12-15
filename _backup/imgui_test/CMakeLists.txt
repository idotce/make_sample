cmake_minimum_required(VERSION 3.8)
project(imgui_test)

set(GUI_LIB glfw_gl3)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_BUILD_TYPE Release)

# add_compile_options(-Wall)

enable_language("RC")
set(ICON_RC "${CMAKE_CURRENT_SOURCE_DIR}/src/icon.rc")

set(IMGUI_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/imgui/imgui.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/imgui/imgui_demo.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/imgui/imgui_draw.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/imgui/imgui_tables.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/imgui/imgui_widgets.cpp)

if("${GUI_LIB}" STREQUAL "win32_dx9")
    set(PROJECT_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/src/main_win32_dx9.cpp)
    set(IMGUI_SOURCES ${IMGUI_SOURCES}
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/imgui/backends/imgui_impl_win32.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/imgui/backends/imgui_impl_dx9.cpp)
elseif("${GUI_LIB}" STREQUAL "glfw_gl3")
    set(PROJECT_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/src/main_glfw_gl3.cpp)
    set(IMGUI_SOURCES ${IMGUI_SOURCES}
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/imgui/backends/imgui_impl_glfw.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/imgui/backends/imgui_impl_opengl3.cpp)
endif()

set(EXECUTABLE ${CMAKE_PROJECT_NAME})

add_executable(${EXECUTABLE} ${PROJECT_SOURCES} ${IMGUI_SOURCES} ${ICON_RC})

target_include_directories(${EXECUTABLE} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src/)

target_include_directories(${EXECUTABLE} SYSTEM PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/imgui/
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/imgui/backends/)

if("${GUI_LIB}" STREQUAL "win32_dx9")
    target_link_libraries(${EXECUTABLE} d3d9.lib d3dcompiler.lib dxgi.lib)
elseif("${GUI_LIB}" STREQUAL "glfw_gl3")
    target_include_directories(${EXECUTABLE} SYSTEM PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/glfw/include/
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/glfw/include/GLFW/)
    target_link_directories(${EXECUTABLE} PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/glfw/lib-vc2010-64/)
    target_link_libraries(${EXECUTABLE} opengl32.lib glfw3.lib)
endif()
