cmake_minimum_required(VERSION 3.1.0)

project(libtest VERSION "1.0.0.0")

option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

include_directories(include)

set(CMAKE_MFC_FLAG 1)
#add_definitions(-DUNICODE -D_UNICODE)
add_definitions(-D_AFXDLL)

aux_source_directory(source SRC_LIST)

if(BUILD_SHARED_LIBS)
    add_library(${PROJECT_NAME} SHARED ${SRC_LIST})
else()
    add_library(${PROJECT_NAME} STATIC ${SRC_LIST})
endif()

file(GLOB PUBLIC_HEADERS "include/*.h")
install(FILES ${PUBLIC_HEADERS} DESTINATION include)

if(BUILD_SHARED_LIBS)
    target_compile_definitions(${PROJECT_NAME} PRIVATE DLL_LIBRARY)
    install(TARGETS ${PROJECT_NAME} LIBRARY DESTINATION lib)
    install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin)
else()
    install(TARGETS ${PROJECT_NAME} LIBRARY DESTINATION lib)
    install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin)
endif()
