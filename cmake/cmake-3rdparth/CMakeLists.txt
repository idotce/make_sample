cmake_minimum_required(VERSION 3.1.0)
project(3rdparty)

set(BUILD_SHARED_LIBS OFF)

set(CURL_STATICLIB ON)
set(CURL_STATIC_CRT ON)
set(CURL_USE_SCHANNEL ON)
set(BUILD_CURL_EXE OFF)
set(BUILD_TESTING OFF)
add_subdirectory(curl)

set(glew-cmake_BUILD_STATIC ON)
set(glew-cmake_BUILD_SHARED OFF)
add_subdirectory(glew-cmake)

set(GLFW_VULKAN_STATIC OFF) # only off on windows/linux
set(GLFW_BUILD_EXAMPLES OFF)
set(GLFW_BUILD_TESTS OFF)
set(GLFW_BUILD_DOCS OFF)
add_subdirectory(glfw)

set(BUILD_STATIC_LIBS ON)
set(JSONCPP_STATIC_WINDOWS_RUNTIME ON)
set(JSONCPP_WITH_TESTS OFF)
add_subdirectory(jsoncpp)

set(BUILD_opencv_world ON)
set(BUILD_TESTS OFF)
set(BUILD_EXAMPLES OFF)
set(INSTALL_C_EXAMPLES OFF)
set(INSTALL_PYTHON_EXAMPLES OFF)
set(BUILD_opencv_python2 OFF)
set(BUILD_opencv_python3 OFF)
set(WITH_EIGEN OFF)
add_subdirectory(opencv)

aux_source_directory(test SRC_LIST)
add_executable(${PROJECT_NAME} ${SRC_LIST})
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)
