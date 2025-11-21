cmake_minimum_required(VERSION 3.10)
project(Test)

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

# 强制静态库编译
set(BUILD_STATIC_LIBS ON CACHE BOOL "Build static libraries" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libraries" FORCE)

# 第三方库目录
set(THIRD_PARTY_DIR ${CMAKE_SOURCE_DIR}/third_party)

# 保存 CMake 策略状态
set(OLD_CMAKE_POLICY_DEFAULT_CMP0077 "$ENV{CMAKE_POLICY_DEFAULT_CMP0077}")

# ======================== curl 配置 ========================
set(CURL_SOURCE_DIR ${THIRD_PARTY_DIR}/curl)
set(CURL_BINARY_DIR ${CMAKE_BINARY_DIR}/third_party/curl)
file(MAKE_DIRECTORY ${CURL_BINARY_DIR})

set(CURL_STATIC_CRT ON CACHE BOOL "" FORCE)
set(CURL_USE_SCHANNEL ON CACHE BOOL "" FORCE)
set(CURL_USE_LIBPSL OFF CACHE BOOL "" FORCE)
set(BUILD_CURL_EXE OFF CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(CURL_STATICLIB ON CACHE BOOL "" FORCE)

add_subdirectory(${CURL_SOURCE_DIR} ${CURL_BINARY_DIR} EXCLUDE_FROM_ALL)
include_directories(${CURL_SOURCE_DIR}/include)

# ======================== jsoncpp 配置 ========================
set(JSONCPP_SOURCE_DIR ${THIRD_PARTY_DIR}/jsoncpp)
set(JSONCPP_BINARY_DIR ${CMAKE_BINARY_DIR}/third_party/jsoncpp)
file(MAKE_DIRECTORY ${JSONCPP_BINARY_DIR})

set(JSONCPP_WITH_TESTS OFF CACHE BOOL "" FORCE)
set(JSONCPP_STATIC_WINDOWS_RUNTIME ON CACHE BOOL "" FORCE)

add_subdirectory(${JSONCPP_SOURCE_DIR} ${JSONCPP_BINARY_DIR} EXCLUDE_FROM_ALL)
include_directories(${JSONCPP_SOURCE_DIR}/include)

# ======================== ExternalProject 准备 ========================
# 恢复策略设置
if(OLD_CMAKE_POLICY_DEFAULT_CMP0077)
    set(ENV{CMAKE_POLICY_DEFAULT_CMP0077} ${OLD_CMAKE_POLICY_DEFAULT_CMP0077})
endif()

# 启用 ExternalProject 模块
include(ExternalProject)

# ======================== OpenCV 配置 ========================
set(OPENCV_INSTALL_DIR ${CMAKE_BINARY_DIR}/install/opencv)

ExternalProject_Add(
    opencv_project
    SOURCE_DIR ${THIRD_PARTY_DIR}/opencv
    BINARY_DIR ${CMAKE_BINARY_DIR}/third_party/opencv
    INSTALL_DIR ${OPENCV_INSTALL_DIR}
    CMAKE_ARGS
        -DCMAKE_MSVC_RUNTIME_LIBRARY=${CMAKE_MSVC_RUNTIME_LIBRARY}
        -DCMAKE_CXX_STANDARD=17
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_opencv_world=ON
        -DOPENCV_FORCE_3RDPARTY_BUILD=ON
        -DBUILD_TESTS=OFF
        -DBUILD_PERF_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_DOCS=OFF
        -DBUILD_opencv_java=OFF
        -DBUILD_opencv_python=OFF
        -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=${OPENCV_INSTALL_DIR}/lib
        -DCMAKE_INCLUDE_OUTPUT_DIRECTORY=${OPENCV_INSTALL_DIR}/include
        -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=${OPENCV_INSTALL_DIR}/bin
        -DCMAKE_INSTALL_PREFIX=${OPENCV_INSTALL_DIR}
    BUILD_COMMAND ${CMAKE_COMMAND} --build . --config Release -j20
    INSTALL_COMMAND ${CMAKE_COMMAND} --install . --config Release
    EXCLUDE_FROM_ALL ON
)
include_directories(${OPENCV_INSTALL_DIR}/include)
link_directories(${OPENCV_INSTALL_DIR}/lib)
link_directories(${OPENCV_INSTALL_DIR}/x64/vc16/staticlib)
set(OPENCV_LIBS IlmImf ippicvmt ippiw ittnotify libjpeg-turbo libopenjp2 libpng libprotobuf libtiff libwebp opencv_world460 quirc zlib)

# ======================== tflite 配置 ========================
set(TFLITE_INSTALL_DIR ${CMAKE_BINARY_DIR}/install/tflite)

ExternalProject_Add(
    tflite_project
    SOURCE_DIR ${THIRD_PARTY_DIR}/tensorflow/tensorflow/lite/c
    BINARY_DIR ${CMAKE_BINARY_DIR}/third_party/tflite
    INSTALL_DIR ${TFLITE_INSTALL_DIR}
    CMAKE_ARGS
        -DCMAKE_MSVC_RUNTIME_LIBRARY=${CMAKE_MSVC_RUNTIME_LIBRARY}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DBUILD_SHARED_LIBS=OFF
        -DTFLITE_ENABLE_GPU=ON
        -DTFLITE_C_BUILD_SHARED_LIBS=OFF
        -DTFLITE_ENABLE_XNNPACK=OFF
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=OFF
        -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=${TFLITE_INSTALL_DIR}/lib
        -DCMAKE_INCLUDE_OUTPUT_DIRECTORY=${TFLITE_INSTALL_DIR}/include
        -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=${TFLITE_INSTALL_DIR}/bin
        -DCMAKE_INSTALL_PREFIX=${TFLITE_INSTALL_DIR}
    BUILD_COMMAND ${CMAKE_COMMAND} --build . --config Release -j20
    INSTALL_COMMAND ${CMAKE_COMMAND} --install . --config Release
    EXCLUDE_FROM_ALL ON
)
include_directories(${TFLITE_INSTALL_DIR}/include)
include_directories(${THIRD_PARTY_DIR}/tensorflow)
include_directories(${CMAKE_BINARY_DIR}/third_party/tflite/flatbuffers/include)
link_directories(${TFLITE_INSTALL_DIR}/lib)
set(TFLITE_LIBS
    tensorflow-lite
    # 根据你的库文件添加以下依赖
    absl_bad_any_cast_impl
    absl_bad_optional_access
    absl_bad_variant_access
    absl_base
    absl_city
    absl_civil_time
    absl_cord
    absl_cord_internal
    absl_cordz_functions
    absl_cordz_handle
    absl_cordz_info
    absl_crc32c
    absl_crc_cord_state
    absl_crc_cpu_detect
    absl_crc_internal
    absl_debugging_internal
    absl_demangle_internal
    absl_exponential_biased
    absl_flags
    absl_flags_commandlineflag
    absl_flags_commandlineflag_internal
    absl_flags_config
    absl_flags_internal
    absl_flags_marshalling
    absl_flags_private_handle_accessor
    absl_flags_program_name
    absl_flags_reflection
    absl_graphcycles_internal
    absl_hash
    absl_hashtablez_sampler
    absl_int128
    absl_kernel_timeout_internal
    absl_log_severity
    absl_low_level_hash
    absl_malloc_internal
    absl_raw_hash_set
    absl_raw_logging_internal
    absl_spinlock_wait
    absl_stacktrace
    absl_status
    absl_str_format_internal
    absl_strerror
    absl_string_view
    absl_strings
    absl_strings_internal
    absl_symbolize
    absl_synchronization
    absl_throw_delegate
    absl_time
    absl_time_zone
    cpuinfo
    eight_bit_int_gemm
    farmhash
    fft2d_fftsg
    fft2d_fftsg2d
    flatbuffers
    pthreadpool
    ruy_allocator
    ruy_apply_multiplier
    ruy_block_map
    ruy_blocking_counter
    ruy_context
    ruy_context_get_ctx
    ruy_cpuinfo
    ruy_ctx
    ruy_denormal
    ruy_frontend
    ruy_have_built_path_for_avx
    ruy_have_built_path_for_avx2_fma
    ruy_have_built_path_for_avx512
    ruy_kernel_arm
    ruy_kernel_avx
    ruy_kernel_avx2_fma
    ruy_kernel_avx512
    ruy_pack_arm
    ruy_pack_avx
    ruy_pack_avx2_fma
    ruy_pack_avx512
    ruy_prepacked_cache
    ruy_prepare_packed_matrices
    ruy_profiler_instrumentation
    ruy_system_aligned_alloc
    ruy_thread_pool
    ruy_trmul
    ruy_tune
    ruy_wait
    tensorflowlite_c
)

# ======================== 主程序配置 ========================
aux_source_directory(src SRC_LIST)
add_executable(${PROJECT_NAME} ${SRC_LIST})

# 调用 ExternalProject
add_dependencies(${PROJECT_NAME}
    opencv_project
    tflite_project
)

# 链接库
target_link_libraries(${PROJECT_NAME}
    libcurl
    jsoncpp_static
    ${OPENCV_LIBS}
    ${TFLITE_LIBS}
)

# 针对Windows的特殊配置
if(WIN32)
    target_link_libraries(${PROJECT_NAME} ws2_32 wldap32 crypt32)
    target_compile_definitions(${PROJECT_NAME} PRIVATE
        _CRT_SECURE_NO_WARNINGS
        CURL_STATICLIB
        OPENCV_STATIC  # 添加OpenCV静态链接宏
        NOMINMAX # TFLITE
    )
endif()

# 针对Linux的特殊配置
if(UNIX AND NOT APPLE)
    target_link_libraries(${PROJECT_NAME} pthread dl)
endif()

# MSVC UTF-8 编码支持
if(MSVC AND CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    target_compile_options(${PROJECT_NAME} PRIVATE "/utf-8")
endif()

# ======================== 安装配置 ========================
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    CONFIGURATIONS Release
)
