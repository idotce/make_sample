cmake_minimum_required(VERSION 3.10)
project(test)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")

#find_package(OpenCV REQUIRED)
#include_directories(${OpenCV_INCLUDE_DIRS})

set(OpenCV_ROOT "d:/Project/cmake_extern/extern/opencv")
set(OpenCV_INCLUDE_DIRS "${OpenCV_ROOT}/include")
set(OpenCV_LIB_DIR "${OpenCV_ROOT}/x64/vc16/staticlib")
include_directories(${OpenCV_INCLUDE_DIRS})
link_directories(${OpenCV_LIB_DIR})

aux_source_directory(src SRC_LIST)
add_executable(${PROJECT_NAME} ${SRC_LIST})

#target_link_libraries(${PROJECT_NAME} ${OpenCV_LIBS})
target_link_libraries(${PROJECT_NAME}
  IlmImf
  ittnotify
  libjpeg-turbo
  libopenjp2
  libpng
  libprotobuf
  libtiff
  libwebp
  opencv_world460
  quirc
  zlib)
