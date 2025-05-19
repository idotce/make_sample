cmake_minimum_required(VERSION 3.1.0)
project(cmake_test) # Change this line.

include_directories(lib/inc)
link_directories(lib/_msys)

aux_source_directory(src SRC_LIST)
add_executable(${PROJECT_NAME} ${SRC_LIST})
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 11)

set(ALL_LIBS ${ALL_LIBS} libtest)
target_link_libraries(${PROJECT_NAME} ${ALL_LIBS})

install(TARGETS ${PROJECT_NAME} DESTINATION bin)
