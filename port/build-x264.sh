#!/bin/bash
# by idotce (idotce@gmail.com)

# 系统
pwd_dir=$(cd `dirname $0`; pwd)
export http_proxy=192.168.1.5:8888
export https_proxy=192.168.1.5:8888
export TOOLCHAIN=/data/opt/toolchain/7.5.0/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu
export PATH=$TOOLCHAIN/bin:$PATH
CROSS=aarch64-linux-gnu-
export CC=${CROSS}gcc
export CXX=${CROSS}g++
export AR=${CROSS}ar
export RANLIB=${CROSS}ranlib
export STRIP=${CROSS}strip
export CFLAGS="-Os -static"
export LDFLAGS="-static"

# 工程代码
base_dir=$pwd_dir/_download
pack_url=https://code.videolan.org/videolan/x264/-/archive/master/x264-master.tar.gz
pack_file=$pwd_dir/_download/x264-master.tar.gz
proj_dir=$pwd_dir/_download/x264-master
build_dir=$pwd_dir/_download/x264-master/_build
build_out=$pwd_dir/_install
prefix_dir=/userdata
if [ ! -d "$base_dir" ]; then
    mkdir -p "$base_dir" || { echo "创建基础目录失败!"; exit 1; }
fi
if [ ! -d "$build_out" ]; then
    mkdir -p "$build_out" || { echo "创建输出目录失败!"; exit 1; }
fi
if [ ! -f "$pack_file" ]; then
    wget "$pack_url" -O "$pack_file" || { echo "下载源码失败!"; exit 1; }
fi
if [ ! -d "$proj_dir" ]; then
    tar -xvf "$pack_file" -C "$base_dir" || { echo "解压源码失败!"; exit 1; }
fi

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

    echo "正在cmake..."
    $proj_dir/configure \
        --build=x86_64-linux-gnu \
        --host=aarch64-linux-gnu \
        --enable-static \
        --disable-shared \
        --disable-opencl \
        --prefix=$prefix_dir
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
    make -j$(nproc)
    if [ $? -ne 0 ]; then
        echo "编译失败!"
        cd - > /dev/null
        return 1
    fi

    echo "正在安装..."
    "$cmake_bin" --install . --config Release
    make install DESTDIR=$build_out
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
    echo "操作完成，按Esc返回主菜单!"
    while true; do
    if read -t 1 -n 1 -r key 2>/dev/null; then
        if [[ "$key" == $'\e' ]]; then
            break
        fi
    fi
    done
done
