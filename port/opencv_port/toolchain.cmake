set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_C_COMPILER arm-linux-gnueabi-gcc)
set(CMAKE_CXX_COMPILER arm-linux-gnueabi-g++)
set(CMAKE_FIND_ROOT_PATH /usr/arm-linux-gnueabi)

#set(CMAKE_C_COMPILER arm-himix200-linux-gcc)
#set(CMAKE_CXX_COMPILER arm-himix200-linux-g++)
#set(CMAKE_FIND_ROOT_PATH /opt/hisi-linux/x86-arm/arm-himix200-linux/target)

#include_directories("/data/ports/_out/usr/local/include")
#link_directories("/data/ports/_out/usr/local/lib")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O2")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
