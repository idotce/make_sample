#!/bin/bash

# 系统
pwd_dir=$(cd `dirname $0`; pwd)

# 代理设置：需要时填写，留空则不启用
proxy=""
if [ -n "$proxy" ]; then
    export http_proxy=$proxy
    export https_proxy=$proxy
fi

# 交叉工具链（按实际路径修改）
export TOOLCHAIN=/data/opt/toolchain/7.5.0/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu
export PATH=$TOOLCHAIN/bin:$PATH
CROSS=aarch64-linux-gnu-
export CC=${CROSS}gcc
export CXX=${CROSS}g++
export AR=${CROSS}ar
export RANLIB=${CROSS}ranlib
export STRIP=${CROSS}strip

# 依赖：x264 需先编译安装到 third_party/_install/aarch64
# 源码包
base_dir=$pwd_dir/_download
pack_url=https://ffmpeg.org/releases/ffmpeg-4.2.tar.gz
pack_file=$base_dir/ffmpeg-4.2.tar.gz
proj_dir=$base_dir/ffmpeg-4.2
build_dir=$proj_dir/_build
build_out=$pwd_dir/../_install/aarch64
prefix_dir=/userdata
if [ ! -d "$base_dir" ]; then
    mkdir -p "$base_dir" || { echo "创建下载目录失败!"; exit 1; }
fi
if [ ! -f "$pack_file" ]; then
    wget "$pack_url" -O "$pack_file" || { echo "下载源码失败!"; exit 1; }
fi
if [ ! -d "$proj_dir" ]; then
    tar -xvf "$pack_file" -C "$base_dir" || { echo "解压源码失败!"; exit 1; }
fi

export CFLAGS="-Os -static -I${TOOLCHAIN}/aarch64-linux-gnu/include -I$build_out/userdata/include"
export LDFLAGS="-static -L${TOOLCHAIN}/aarch64-linux-gnu/lib -L$build_out/userdata/lib -lpthread"

# 主菜单函数
main_menu() {
    clear
    echo "1 - configure."
    echo "2 - build."
    echo "3 - clean."
    echo "x - Exit."
    echo ""
}

main_configure() {
    if [ ! -d "$build_dir" ]; then
        mkdir -p "$build_dir" || { echo "创建编译目录失败!"; exit 1; }
    fi
    cd "$build_dir" || { echo "进入编译目录失败!"; exit 1; }

    echo "正在configure..."
    $proj_dir/configure \
        --cross-prefix=${CROSS} \
        --arch=aarch64 \
        --target-os=linux \
        --enable-cross-compile \
        --enable-static \
        --enable-gpl \
        --enable-libx264 \
        --enable-nonfree \
        --disable-ffplay \
        --disable-ffprobe \
        --disable-avdevice \
        --disable-doc \
        --disable-symver \
        --prefix=$prefix_dir
    if [ $? -ne 0 ]; then
        echo "configure 失败!"
        cd - > /dev/null
        return 1
    fi
}

main_build() {
    if [ ! -d "$build_dir" ]; then
        echo "编译目录不存在，请先运行 configure"
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
    if [ -d "$build_out" ]; then
        rm -rf "$build_out"
    fi
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
        1) main_configure;;
        2) main_build;;
        3) main_clean;;
        x|X) echo "退出程序" && exit 0;;
        *) echo "" && echo "请选择一个有效的功能!";;
    esac
    echo ""
    echo "操作完成，按任意键返回主菜单!"
    read -n 1 -s -r
done
