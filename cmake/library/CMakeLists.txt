cmake_minimum_required(VERSION 3.10)
project(cmake_test) # Change this line.

if(USE_TEST)
    add_definitions(-DUSE_TEST)
    message("USE_TEST = ON")
else()
    message("USE_TEST = OFF")
endif(USE_TEST)

# libtest 编译安装目录：先进入 lib 目录用脚本编译安装后再编译本工程
set(LIBTEST_ROOT ${CMAKE_SOURCE_DIR}/lib/_install)
include_directories(${LIBTEST_ROOT}/inc)
link_directories(${LIBTEST_ROOT}/lib)

aux_source_directory(src SRC_LIST)
add_executable(${PROJECT_NAME} ${SRC_LIST})
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

target_link_libraries(${PROJECT_NAME} libtest)

install(TARGETS ${PROJECT_NAME} DESTINATION bin)
