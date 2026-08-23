#!/bin/bash

# 系统
pwd_dir=$(cd `dirname $0`; pwd)

# 代理设置：需要时填写，留空则不启用
proxy=""
if [ -n "$proxy" ]; then
    export http_proxy=$proxy
    export https_proxy=$proxy
fi
cmake_bin=cmake

# 源码包
base_dir=$pwd_dir/_download
pack_url=https://curl.se/download/curl-8.16.0.tar.gz
pack_file=$base_dir/curl-8.16.0.tar.gz
proj_dir=$base_dir/curl-8.16.0
build_dir=$proj_dir/_build
build_out=$pwd_dir/../ios/curl/

# 依赖：openssl 需先用 patch/build-ios-openssl.sh 编译好
if [ ! -d "$base_dir" ]; then
    mkdir -p "$base_dir" || { echo "创建下载目录失败!"; exit 1; }
fi
if [ ! -f "$pack_file" ]; then
    wget "$pack_url" -O "$pack_file" || { echo "下载源码失败!"; exit 1; }
fi
if [ ! -d "$proj_dir" ]; then
    tar -xvf "$pack_file" -C "$base_dir" || { echo "解压源码失败!"; exit 1; }
fi

# CMAKE选项
OPENSSL_DIR=$pwd_dir/../patch/openssl_ios
CMAKE_OPT=(
    # 系统选项
    -DCMAKE_TOOLCHAIN_FILE=$pwd_dir"/../patch/apple.toolchain.cmake"
    -DPLATFORM=OS64
    # 库类型
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_STATIC_LIBS=ON
    -DBUILD_SHARED_LIBS=OFF
    # 功能和依赖库
    -DCURL_USE_SCHANNEL=OFF
    -DCURL_USE_OPENSSL=ON
    -DOPENSSL_ROOT_DIR=$OPENSSL_DIR
    -DOPENSSL_INCLUDE_DIR=$OPENSSL_DIR/include
    -DOPENSSL_CRYPTO_LIBRARY=$OPENSSL_DIR/lib/libcrypto.a
    -DOPENSSL_SSL_LIBRARY=$OPENSSL_DIR/lib/libssl.a
    -DCURL_USE_LIBPSL=OFF
    -DBUILD_CURL_EXE=OFF
    -DBUILD_TESTING=OFF
    # 输出配置
    -DCMAKE_INSTALL_PREFIX="$build_out"
)

# 主菜单函数
main_menu() {
    clear
    echo "1 - cmake."
    echo "2 - build."
    echo "3 - clean."
    echo "x - Exit."
    echo ""
}

main_cmake() {
    if [ ! -d "$build_dir" ]; then
        mkdir -p "$build_dir" || { echo "创建编译目录失败!"; exit 1; }
    fi
    cd "$build_dir" || { echo "进入编译目录失败!"; exit 1; }
    if [ -f "CMakeCache.txt" ]; then
        rm -f CMakeCache.txt
    fi

    echo "正在cmake..."
    "$cmake_bin" -G Xcode "${CMAKE_OPT[@]}" "$proj_dir"
    if [ $? -ne 0 ]; then
        echo "cmake 配置失败!"
        cd - > /dev/null
        return 1
    fi
}

main_build() {
    if [ ! -d "$build_dir" ]; then
        echo "编译目录不存在，请先运行 cmake"
        return 1
    fi
    cd "$build_dir" || { echo "进入编译目录失败!"; exit 1; }

    echo "正在编译..."
    "$cmake_bin" --build . --config Release --parallel $(sysctl -n hw.ncpu)
    if [ $? -ne 0 ]; then
        echo "编译失败!"
        cd - > /dev/null
        return 1
    fi

    echo "正在安装..."
    if [ -d "$build_out" ]; then
        rm -rf "$build_out"
    fi
    "$cmake_bin" --install . --config Release
    if [ $? -ne 0 ]; then
        echo "安装失败!"
        cd - > /dev/null
        return 1
    fi
}

main_clean() {
    if [ -d "$build_dir" ]; then
        rm -rf "$build_dir"
        echo "已清理构建目录!"
    else
        echo "构建目录不存在，无需清理!"
    fi
}

# 主循环
while true; do
    main_menu
    read -p "请选择功能: " mainmenu
    case $mainmenu in
        1) main_cmake;;
        2) main_build;;
        3) main_clean;;
        x|X) echo "退出程序" && exit 0;;
        *) echo "" && echo "请选择一个有效的功能!";;
    esac
    echo ""
    echo "操作完成，按任意键返回主菜单!"
    read -n 1 -s -r
done
