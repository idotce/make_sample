#!/bin/bash
# by idotce (idotce@gmail.com)

export http_proxy=192.168.1.5:8888
export https_proxy=192.168.1.5:8888

export TOOLCHAIN=/data/opt/toolchain/7.5.0/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu
export PATH=$TOOLCHAIN/bin:$PATH

#CROSS=arm-linux-gnueabi-
CROSS=aarch64-linux-gnu-
export CC=${CROSS}gcc
export CXX=${CROSS}g++
export AR=${CROSS}ar
export RANLIB=${CROSS}ranlib
export STRIP=${CROSS}strip

pwd_dir=$(cd `dirname $0`; pwd)
echo "当前工作目录: ${pwd_dir}"

export CFLAGS="-Os -static -fPIC"
export LDFLAGS="-static -lpthread -lm"

gz_url=https://code.videolan.org/videolan/x264/-/archive/master/x264-master.tar.gz
gz_file=x264-master.tar.gz
code_dir=x264-master

build_dir="_build"
out_dir="_out"

if [ ! -f $gz_file ]; then
    wget $gz_url -O $gz_file || { echo "下载源码失败"; exit 1; }
fi

if [ ! -d $code_dir ]; then
    tar -xzvf $gz_file || { echo "解压源码失败"; exit 1; }
fi

if [ ! -d ${pwd_dir}/${out_dir} ]; then
    mkdir -p ${pwd_dir}/${out_dir} || { echo "创建目录失败"; exit 1; }
fi

if [ -d $code_dir ]; then
    cd $code_dir || { echo "进入源码目录失败"; exit 1; }
    rm -rf $build_dir; mkdir $build_dir; cd $build_dir
    make distclean >/dev/null 2>&1 || true  # 清理可能的旧编译文件

    ../configure \
        --cross-prefix=${CROSS} \
        --prefix=/userdata \
        --build=x86_64-linux-gnu \
        --host=aarch64-linux-gnu \
        --enable-static \
        --disable-shared \
        --disable-opencl \
        --extra-cflags="${CFLAGS}" \
        --extra-ldflags="${LDFLAGS}"

    make -j$(nproc) || { echo "编译失败"; exit 1; }
    make install DESTDIR=${pwd_dir}/${out_dir}/ || { echo "安装失败"; exit 1; }
    echo "编译完成，输出目录: ${pwd_dir}/${out_dir}"
fi
