cmake_minimum_required(VERSION 3.10)
project(test)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")

# 设置安装前缀
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/output" CACHE PATH "Install path prefix" FORCE)
endif()

# 设置库文件搜索路径（根据你的实际路径修改）
set(OPENCV_ROOT "d:/Project/cmake_extern/extern/opencv")
set(CURL_ROOT "d:/Project/cmake_extern/extern/curl")
set(JSONCPP_ROOT "d:/Project/cmake_extern/extern/jsoncpp")
set(TENSORFLOW_LITE_ROOT "d:/Project/cmake_extern/extern/tensorflow")

# 查找库 OpenCV
set(OPENCV_INCLUDE_DIRS "${OPENCV_ROOT}/include")
set(OPENCV_LIB_DIR "${OPENCV_ROOT}/x64/vc16/staticlib")
link_directories(${OPENCV_LIB_DIR})
set(OPENCV_LIBS IlmImf ippicvmt ippiw ittnotify libjpeg-turbo libopenjp2 libpng libprotobuf libtiff libwebp opencv_world460 quirc zlib)

# 查找库 CURL
set(CURL_INCLUDE_DIRS "${CURL_ROOT}/include")
set(CURL_LIB_DIR "${CURL_ROOT}/lib")
link_directories(${CURL_LIB_DIR})
set(CURL_LIBRARIES libcurl Iphlpapi Secur32)

# 查找库 JsonCpp
set(JSONCPP_INCLUDE_DIRS "${JSONCPP_ROOT}/include")
set(JSONCPP_LIB_DIR "${JSONCPP_ROOT}/lib")
link_directories(${JSONCPP_LIB_DIR})
set(JSONCPP_LIBRARIES jsoncpp)

# 查找库 TensorFlow Lite
set(TENSORFLOW_LITE_INCLUDE_DIRS
    "${TENSORFLOW_LITE_ROOT}/include"
    "${TENSORFLOW_LITE_ROOT}/include/tensorflow/lite"
)
set(TENSORFLOW_LITE_LIB_DIR "${TENSORFLOW_LITE_ROOT}/lib")
link_directories(${TENSORFLOW_LITE_LIB_DIR})

# TensorFlow Lite 库文件（根据实际文件名调整）
set(TENSORFLOW_LITE_LIBRARIES tensorflow-lite)

# 包含头文件目录
include_directories(
    ${OPENCV_INCLUDE_DIRS}
    ${CURL_INCLUDE_DIRS}
    ${JSONCPP_INCLUDE_DIRS}
    ${TENSORFLOW_LITE_INCLUDE_DIRS}
)

# 添加可执行文件
aux_source_directory(src SRC_LIST)
add_executable(${PROJECT_NAME} ${SRC_LIST})

# 链接库
target_link_libraries(${PROJECT_NAME}
    ${OPENCV_LIBS}
    ${CURL_LIBRARIES}
    ${JSONCPP_LIBRARIES}
    ${TENSORFLOW_LITE_LIBRARIES}
)

# 添加静态库链接标志（Windows需要）
if(WIN32)
    target_link_libraries(${PROJECT_NAME} ws2_32 wldap32 crypt32)
    target_compile_definitions(${PROJECT_NAME} PRIVATE
        CURL_STATICLIB
        JSON_STATIC
        NOMINMAX  # TensorFlow Lite 需要这个定义
        TFLITE_STATIC_LIBRARY_BUILD  # 如果使用静态库
    )
endif()

# utf8编码支持
if(MSVC)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        target_compile_options(${PROJECT_NAME} PRIVATE "/utf-8")
    endif()
endif()

# 安装配置
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    CONFIGURATIONS Release
)