cmake_minimum_required(VERSION 3.10)
project(test)

# ======================== 全局基础配置 ========================
# 主项目使用 C++20 标准
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# MSVC 静态运行时配置
if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd")
endif()

# ======================== extern 配置 ========================
# 第三方库目录
set(THIRD_PARTY_DIR ${CMAKE_SOURCE_DIR}/../extern)

# Curl
include_directories(${THIRD_PARTY_DIR}/curl/include)
link_directories(${THIRD_PARTY_DIR}/curl/lib)
link_directories(${THIRD_PARTY_DIR}/../patch/openssl_arm64/lib)
if(WIN32)
    set(CURL_LIBS libcurl)
elseif(ANDROID)
    set(CURL_LIBS curl ssl crypto)
endif()

# JsonCPP
include_directories(${THIRD_PARTY_DIR}/jsoncpp/include)
link_directories(${THIRD_PARTY_DIR}/jsoncpp/lib)

# OpenCV
if(WIN32)
    include_directories(${THIRD_PARTY_DIR}/opencv/include)
    link_directories(${THIRD_PARTY_DIR}/opencv/x64/vc16/staticlib)
    #
    file(GLOB OPENCV_LIBS_RAW "${THIRD_PARTY_DIR}/opencv/x64/vc16/staticlib/*.lib")
    set(OPENCV_LIBS "")
    foreach(LIB_FILE ${OPENCV_LIBS_RAW})
        get_filename_component(LIB_NAME ${LIB_FILE} NAME)
        list(APPEND OPENCV_LIBS ${LIB_NAME})
    endforeach()
elseif(ANDROID)
    include_directories(${THIRD_PARTY_DIR}/opencv/sdk/native/jni/include)
    link_directories(${THIRD_PARTY_DIR}/opencv/sdk/native/staticlibs/arm64-v8a)
    link_directories(${THIRD_PARTY_DIR}/opencv/sdk/native/3rdparty/libs/arm64-v8a)
    #
    file(GLOB OPENCV_STATIC_LIBS "${THIRD_PARTY_DIR}/opencv/sdk/native/staticlibs/arm64-v8a/*.a")
    file(GLOB OPENCV_3RDPARTY_LIBS "${THIRD_PARTY_DIR}/opencv/sdk/native/3rdparty/libs/arm64-v8a/*.a")
    set(OPENCV_LIBS_RAW "")
    list(APPEND OPENCV_LIBS_RAW ${OPENCV_STATIC_LIBS})
    list(APPEND OPENCV_LIBS_RAW ${OPENCV_3RDPARTY_LIBS})
    set(OPENCV_LIBS "")
    foreach(LIB_FILE ${OPENCV_LIBS_RAW})
        get_filename_component(LIB_NAME ${LIB_FILE} NAME)
        string(REGEX REPLACE "^lib(.*)\\.a$" "\\1" LIB_NAME_CLEAN ${LIB_NAME})
        list(APPEND OPENCV_LIBS ${LIB_NAME_CLEAN})
    endforeach()
endif()

# TfLite
include_directories(${THIRD_PARTY_DIR}/tensorflow/include)
if(WIN32)
    link_directories(${THIRD_PARTY_DIR}/tensorflow/lib/Release)
    file(GLOB TFLITE_LIBS_RAW "${THIRD_PARTY_DIR}/tensorflow/lib/Release/*.lib")
    set(TFLITE_LIBS tensorflow-lite)
    foreach(LIB_FILE ${TFLITE_LIBS_RAW})
        get_filename_component(LIB_NAME ${LIB_FILE} NAME)
        list(APPEND TFLITE_LIBS ${LIB_NAME})
    endforeach()
elseif(ANDROID)
    link_directories(${THIRD_PARTY_DIR}/tensorflow/lib)
    file(GLOB TFLITE_LIBS_RAW "${THIRD_PARTY_DIR}/tensorflow/lib/*.a")
    set(TFLITE_LIBS tensorflow-lite)
    foreach(LIB_FILE ${TFLITE_LIBS_RAW})
        get_filename_component(LIB_NAME ${LIB_FILE} NAME)
        string(REGEX REPLACE "^lib(.*)\\.a$" "\\1" LIB_NAME_CLEAN ${LIB_NAME})
        list(APPEND TFLITE_LIBS ${LIB_NAME_CLEAN})
    endforeach()
endif()

#list(REMOVE_ITEM TFLITE_LIBS "tensorflow-lite.lib")
#list(REMOVE_ITEM TFLITE_LIBS "tensorflowlite_c.lib")
#message(STATUS "${TFLITE_LIBS}")

# ======================== 主程序配置 ========================
include_directories(src)

aux_source_directory(src SRC_LIST)
add_executable(${PROJECT_NAME} ${SRC_LIST})

# 链接库
target_link_libraries(${PROJECT_NAME}
    ${CURL_LIBS}
    jsoncpp
    ${OPENCV_LIBS}
    ${TFLITE_LIBS}
)

# 针对Windows的特殊配置
if(WIN32)
    target_link_libraries(${PROJECT_NAME} ws2_32 wldap32 crypt32 iphlpapi secur32)
    target_compile_definitions(${PROJECT_NAME} PRIVATE
        _CRT_SECURE_NO_WARNINGS
        CURL_STATICLIB
        OPENCV_STATIC  # 添加OpenCV静态链接宏
        TFL_STATIC_LIBRARY_BUILD # TFLITE
        NOMINMAX # TFLITE
    )
elseif(ANDROID)
    target_link_libraries(${PROJECT_NAME} log dl)
endif()

# MSVC UTF-8 编码支持
if(MSVC AND CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    target_compile_options(${PROJECT_NAME} PRIVATE "/utf-8")
endif()

# ======================== 安装配置 ========================
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    CONFIGURATIONS Release
)