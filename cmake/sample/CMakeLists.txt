cmake_minimum_required(VERSION 3.1.0)
project(cmake_test) # Change this line.

if(USE_TEST)
    add_definitions(-DUSE_TEST)
    message("USE_TEST = ON")
else()
    message("USE_TEST = OFF")
endif(USE_TEST)

aux_source_directory(src SRC_LIST)
add_executable(${PROJECT_NAME} ${SRC_LIST})
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

