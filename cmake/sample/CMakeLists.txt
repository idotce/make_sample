cmake_minimum_required(VERSION 3.10)
project(Test)

# ======================== 全局基础配置 ========================
# 主项目使用 C++17 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# MSVC 静态运行时配置
# 注意：CMAKE_MSVC_RUNTIME_LIBRARY 已足够；不要再叠加 /MT /MTd 编译选项，二者重复且易冲突
if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

# ======================== 主程序配置 ========================
aux_source_directory(src SRC_LIST)
add_executable(${PROJECT_NAME} ${SRC_LIST})

# MSVC UTF-8 编码支持
if(MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE "/utf-8")
endif()

# ======================== 安装配置 ========================
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    CONFIGURATIONS Release
)