#!/bin/bash

#
# by idotce (idotce@gmail.com)
#

export TOOLCHAIN=/data/opt/toolchain/7.5.0/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu
export PATH=$TOOLCHAIN/bin:$PATH
export https_proxy=192.168.1.5:8888

export CC=aarch64-linux-gnu-gcc
export CXX=aarch64-linux-gnu-g++
export AR=aarch64-linux-gnu-ar
export RANLIB=aarch64-linux-gnu-ranlib
export STRIP=aarch64-linux-gnu-strip

export CFLAGS="-Os -static"  # 优化体积并静态编译
export LDFLAGS="-static"     # 静态链接

pwd_dir=$(cd `dirname $0`; pwd)
echo "当前工作目录: ${pwd_dir}"

gz_url=https://mirrors.ustc.edu.cn/gnu/ncurses/ncurses-6.4.tar.gz
gz_file=ncurses-6.4.tar.gz
code_dir=ncurses-6.4

out_dir="_out"

if [ ! -f $gz_file ]; then
    wget $gz_url -O $gz_file || { echo "下载源码失败"; exit 1; }
fi

if [ ! -d $code_dir ]; then
    tar -xzvf $gz_file || { echo "解压源码失败"; exit 1; }
fi

if [ -d $code_dir ]; then
    cd $code_dir || { echo "进入源码目录失败"; exit 1; }
    make distclean >/dev/null 2>&1 || true  # 清理可能的旧编译文件

    ./configure \
        --build=x86_64-linux-gnu \
        --host=aarch64-linux-gnu \
        --prefix=/userdata \
        --with-static-libs \
        --without-shared \
        --without-debug \
        --enable-widec \
        --with-termlib=tinfo \
        --disable-dependency-tracking

    make -j8 || { echo "编译失败"; exit 1; }

    #rm -rf ${pwd_dir}/${out_dir}
    mkdir -p ${pwd_dir}/${out_dir} || { echo "创建输出目录失败"; exit 1; }
    make install DESTDIR=${pwd_dir}/${out_dir}/ || { echo "安装失败"; exit 1; }

    echo "编译完成，输出目录: ${pwd_dir}/${out_dir}"
fi
