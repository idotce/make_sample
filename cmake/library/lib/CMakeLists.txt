cmake_minimum_required(VERSION 3.10)

project(libtest VERSION "1.0.0.0")

option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

include_directories(inc)

aux_source_directory(src SRC_LIST)

if(BUILD_SHARED_LIBS)
    add_library(${PROJECT_NAME} SHARED ${SRC_LIST})
    target_compile_definitions(${PROJECT_NAME} PRIVATE DLL_LIBRARY)
else()
    add_library(${PROJECT_NAME} STATIC ${SRC_LIST})
endif()

set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

# 安装：头文件到 inc，动态库到 lib，Windows 导入库/静态库到 lib，dll 到 bin
file(GLOB PUBLIC_HEADERS "inc/*.h")
install(FILES ${PUBLIC_HEADERS} DESTINATION inc)
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
