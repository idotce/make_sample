#!/bin/bash

#
# by idotce (idotce@gmail.com)
#

export TOOLCHAIN=/data/opt/toolchain/7.5.0/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu
export PATH=$TOOLCHAIN/bin:$PATH

export CC=aarch64-linux-gnu-gcc
export CXX=aarch64-linux-gnu-g++
export AR=aarch64-linux-gnu-ar
export RANLIB=aarch64-linux-gnu-ranlib
export STRIP=aarch64-linux-gnu-strip

export CFLAGS="-Os -static"  # -Os优化体积，-static静态编译
export LDFLAGS="-static"     # 链接时静态链接所有库

pwd_dir=$(cd `dirname $0`; pwd)
echo ${pwd_dir}

gz_url=https://www.ohse.de/uwe/releases/lrzsz-0.12.20.tar.gz
gz_file=lrzsz-0.12.20.tar.gz
code_dir=lrzsz-0.12.20

out_dir="_out"

if [ ! -f $gz_file ]; then
    wget $gz_url -O $gz_file
fi

if [ ! -d $code_dir ]; then
    tar -xzvf $gz_file
fi

if [ -d $code_dir ]; then
    cd $code_dir;
    make distclean

    ./configure \
        --build=x86_64-linux-gnu \
        --host=aarch64-linux-gnu \
        --prefix=/userdata \
        --disable-nls

    make -j8

    rm -rf ${pwd_dir}/${out_dir}; mkdir ${pwd_dir}/${out_dir}
    make install DESTDIR=${pwd_dir}/${out_dir}/
fi
