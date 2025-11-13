cmake_minimum_required(VERSION 3.10)
project(test)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(MSVC)
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
endif()

# 设置安装前缀
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/output" CACHE PATH "Install path prefix" FORCE)
endif()

# 设置库文件搜索路径（根据你的实际路径修改）
if(WIN32)
    set(OPENCV_ROOT "d:/Project/cmake_extern/extern/opencv")
    set(CURL_ROOT "d:/Project/cmake_extern/extern/curl")
    set(JSONCPP_ROOT "d:/Project/cmake_extern/extern/jsoncpp")
    set(TENSORFLOW_LITE_ROOT "d:/Project/cmake_extern/extern/tensorflow")
elseif(ANDROID)
    set(OPENCV_ROOT "d:/Project/cmake_extern/extern_apk/opencv")
    set(CURL_ROOT "d:/Project/cmake_extern/extern_apk/curl")
    set(JSONCPP_ROOT "d:/Project/cmake_extern/extern_apk/jsoncpp")
    set(TENSORFLOW_LITE_ROOT "d:/Project/cmake_extern/extern_apk/tensorflow")
endif()

# 查找库 OpenCV
if(WIN32)
    set(OPENCV_INCLUDE_DIRS "${OPENCV_ROOT}/include")
    set(OPENCV_LIB_DIR "${OPENCV_ROOT}/x64/vc16/staticlib")
    link_directories(${OPENCV_LIB_DIR})
    set(OPENCV_LIBS IlmImf ippicvmt ippiw ittnotify libjpeg-turbo libopenjp2 libpng libprotobuf libtiff libwebp opencv_world460 quirc zlib)
elseif(ANDROID)
    set(OPENCV_INCLUDE_DIRS "${OPENCV_ROOT}/sdk/native/jni/include")
    set(OPENCV_LIB_DIR "${OPENCV_ROOT}/sdk/native/staticlibs/arm64-v8a")
    set(OPENCV_3RD_LIB_DIR "${OPENCV_ROOT}/sdk/native/3rdparty/libs/arm64-v8a")
    link_directories(${OPENCV_LIB_DIR})
    link_directories(${OPENCV_3RD_LIB_DIR})
    set(OPENCV_LIBS IlmImf ittnotify libjpeg-turbo libopenjp2 libpng libprotobuf libtiff libwebp opencv_world quirc zlib)
endif()

# 查找库 CURL
set(CURL_INCLUDE_DIRS "${CURL_ROOT}/include")
set(CURL_LIB_DIR "${CURL_ROOT}/lib")
link_directories(${CURL_LIB_DIR})
if(WIN32)
    set(CURL_LIBRARIES libcurl Iphlpapi Secur32)
elseif(ANDROID)
    set(CURL_LIBRARIES curl)
endif()

# 查找库 JsonCpp
set(JSONCPP_INCLUDE_DIRS "${JSONCPP_ROOT}/include")
set(JSONCPP_LIB_DIR "${JSONCPP_ROOT}/lib")
link_directories(${JSONCPP_LIB_DIR})
set(JSONCPP_LIBRARIES jsoncpp)

# 查找库 TensorFlow Lite
set(TENSORFLOW_LITE_INCLUDE_DIRS
    "${TENSORFLOW_LITE_ROOT}/include"
    "${TENSORFLOW_LITE_ROOT}/include/tensorflow/lite"
)
set(TENSORFLOW_LITE_LIB_DIR "${TENSORFLOW_LITE_ROOT}/lib")
link_directories(${TENSORFLOW_LITE_LIB_DIR})

# 设置 TensorFlow Lite 及其依赖库
set(TENSORFLOW_LITE_LIBRARIES
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

# 包含头文件目录
include_directories(
    ${OPENCV_INCLUDE_DIRS}
    ${CURL_INCLUDE_DIRS}
    ${JSONCPP_INCLUDE_DIRS}
    ${TENSORFLOW_LITE_INCLUDE_DIRS}
)

# 添加可执行文件
aux_source_directory(src SRC_LIST)
add_executable(${PROJECT_NAME} ${SRC_LIST})

# 链接库
target_link_libraries(${PROJECT_NAME}
    ${OPENCV_LIBS}
    ${CURL_LIBRARIES}
    ${JSONCPP_LIBRARIES}
    ${TENSORFLOW_LITE_LIBRARIES}
    # 添加一些系统库
    #ws2_32
    #crypt32
)

# 添加静态库链接标志（Windows需要）
if(WIN32)
    target_link_libraries(${PROJECT_NAME} ws2_32 wldap32 crypt32)
    target_compile_definitions(${PROJECT_NAME} PRIVATE
        CURL_STATICLIB
        JSON_STATIC
        NOMINMAX  # TensorFlow Lite 需要这个定义
        TFLITE_STATIC_LIBRARY_BUILD  # 如果使用静态库
    )
endif()

# utf8编码支持
if(MSVC)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        target_compile_options(${PROJECT_NAME} PRIVATE "/utf-8")
    endif()
endif()

# 安装配置
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    CONFIGURATIONS Release
)