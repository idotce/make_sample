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

# ======================== third_party 配置 ========================
# 第三方库目录
if(WIN32)
    set(THIRD_PARTY_DIR ${CMAKE_SOURCE_DIR}/../third_party/win32)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(THIRD_PARTY_DIR ${CMAKE_SOURCE_DIR}/../third_party/macos)
elseif(ANDROID)
    set(THIRD_PARTY_DIR ${CMAKE_SOURCE_DIR}/../third_party/apk)
endif()

# Curl
include_directories(${THIRD_PARTY_DIR}/curl/include)
link_directories(${THIRD_PARTY_DIR}/curl/lib)
if(WIN32)
    set(CURL_LIBS libcurl)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(CURL_LIBS curl)
elseif(ANDROID)
    link_directories(${CMAKE_SOURCE_DIR}/../third_party/patch/openssl_arm64/lib)
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
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    include_directories(${THIRD_PARTY_DIR}/opencv/include/opencv4)
    link_directories(${THIRD_PARTY_DIR}/opencv/lib)
    link_directories(${THIRD_PARTY_DIR}/opencv/lib/opencv4/3rdparty)
    #
    file(GLOB OPENCV_STATIC_LIBS "${THIRD_PARTY_DIR}/opencv/lib/*.a")
    file(GLOB OPENCV_3RDPARTY_LIBS "${THIRD_PARTY_DIR}/opencv/lib/opencv4/3rdparty/*.a")
    set(OPENCV_LIBS_RAW "")
    list(APPEND OPENCV_LIBS_RAW ${OPENCV_STATIC_LIBS})
    list(APPEND OPENCV_LIBS_RAW ${OPENCV_3RDPARTY_LIBS})
    set(OPENCV_LIBS "")
    foreach(LIB_FILE ${OPENCV_LIBS_RAW})
        get_filename_component(LIB_NAME ${LIB_FILE} NAME)
        string(REGEX REPLACE "^lib(.*)\\.a$" "\\1" LIB_NAME_CLEAN ${LIB_NAME})
        list(APPEND OPENCV_LIBS ${LIB_NAME_CLEAN})
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
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    link_directories(${THIRD_PARTY_DIR}/tensorflow/lib)
    file(GLOB TFLITE_LIBS_RAW "${THIRD_PARTY_DIR}/tensorflow/lib/*.a")
    set(TFLITE_LIBS tensorflow-lite)
    foreach(LIB_FILE ${TFLITE_LIBS_RAW})
        get_filename_component(LIB_NAME ${LIB_FILE} NAME)
        string(REGEX REPLACE "^lib(.*)\\.a$" "\\1" LIB_NAME_CLEAN ${LIB_NAME})
        list(APPEND TFLITE_LIBS ${LIB_NAME_CLEAN})
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

# glew
if(WIN32)
    include_directories(${THIRD_PARTY_DIR}/glew/include)
    link_directories(${THIRD_PARTY_DIR}/glew/lib)
    set(GLEW_LIBS "glew")
endif()

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
    ${GLEW_LIBS}
)

# 宏定义
target_compile_definitions(${PROJECT_NAME} PRIVATE
    _CRT_SECURE_NO_WARNINGS
    CURL_STATICLIB  # Curl
    OPENCV_STATIC  # OpenCV
    TFL_STATIC_LIBRARY_BUILD # TFLITE
    NOMINMAX # TFLITE
    GLEW_STATIC # glew
)

# 平台相关链接库
if(WIN32)
    target_link_libraries(${PROJECT_NAME} ws2_32 wldap32 crypt32 iphlpapi secur32 opengl32)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    target_link_libraries(${PROJECT_NAME} ldap z /opt/homebrew/lib/libidn2.dylib "-framework CoreFoundation" "-framework SystemConfiguration" "-framework OpenCL")
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
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    PUBLIC_HEADER DESTINATION include
    CONFIGURATIONS Release
)