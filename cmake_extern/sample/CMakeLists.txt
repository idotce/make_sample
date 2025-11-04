cmake_minimum_required(VERSION 3.10)
project(test)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")

# 设置库文件搜索路径（根据你的实际路径修改）
set(OPENCV_ROOT "d:/Project/cmake_extern/extern/opencv")
set(CURL_ROOT "d:/Project/cmake_extern/extern/curl")
set(JSONCPP_ROOT "d:/Project/cmake_extern/extern/jsoncpp")

# 查找库 OpenCV
#find_package(OpenCV REQUIRED)
set(OPENCV_INCLUDE_DIRS "${OPENCV_ROOT}/include")
set(OPENCV_LIB_DIR "${OPENCV_ROOT}/x64/vc16/staticlib")
link_directories(${OPENCV_LIB_DIR})
set(OPENCV_LIBS IlmImf ittnotify libjpeg-turbo libopenjp2 libpng libprotobuf libtiff libwebp opencv_world460 quirc zlib)

# 查找库 CURL
#find_package(CURL REQUIRED)
set(CURL_INCLUDE_DIRS "${CURL_ROOT}/include")
set(CURL_LIB_DIR "${CURL_ROOT}/lib")
link_directories(${CURL_LIB_DIR})
set(CURL_LIBRARIES libcurl Iphlpapi Secur32)

# 查找库 JsonCpp
#find_package(JsonCpp REQUIRED)
set(JSONCPP_INCLUDE_DIRS "${JSONCPP_ROOT}/include")
set(JSONCPP_LIB_DIR "${JSONCPP_ROOT}/lib")
link_directories(${JSONCPP_LIB_DIR})
set(JSONCPP_LIBRARIES jsoncpp)

# 包含头文件目录
include_directories(
    ${OPENCV_INCLUDE_DIRS}
    ${CURL_INCLUDE_DIRS}
    ${JSONCPP_INCLUDE_DIRS}
)

# 添加可执行文件
aux_source_directory(src SRC_LIST)
add_executable(${PROJECT_NAME} ${SRC_LIST})

# 链接库
target_link_libraries(${PROJECT_NAME}
    ${OPENCV_LIBS}
    ${CURL_LIBRARIES}
    ${JSONCPP_LIBRARIES}
)

# 添加静态库链接标志（Windows需要）
if(WIN32)
    target_link_libraries(${PROJECT_NAME} ws2_32 wldap32 crypt32)
    target_compile_definitions(${PROJECT_NAME} PRIVATE CURL_STATICLIB JSON_STATIC)
endif()

# utf8编码支持
if(MSVC)
    # 设置源代码使用 UTF-8 编码
    add_compile_options("$<$<C_COMPILER_ID:MSVC>:/utf-8>")

    # 或者使用更明确的方式
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        target_compile_options(${PROJECT_NAME} PRIVATE "/utf-8")
    endif()
endif()
