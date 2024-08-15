#!/bin/bash

#
# by idotce (idotce@gmail.com)
#

#CROSS=arm-linux-gnueabi-
CROSS=arm-himix200-linux-

pwd_dir=$(cd `dirname $0`; pwd)
echo ${pwd_dir}

gz_url=http://download.videolan.org/x264/snapshots/last_stable_x264.tar.bz2
gz_file=last_stable_x264.tar.bz2
code_dir=x264

build_dir="_build"
out_dir="_out"

export http_proxy=http://192.168.1.10:8888
export https_proxy=http://192.168.1.10:8888

if [ ! -f $gz_file ]; then
    wget $gz_url -O $gz_file
fi

if [ ! -d $code_dir ]; then
    tar -xvf $gz_file
    mv x264-* $code_dir
fi

if [ -d $code_dir ]; then
    cd $code_dir; rm -rf $build_dir; mkdir $build_dir; cd $build_dir

    ../configure \
      --prefix=/usr/local \
      --host=arm-linux \
      --cross-prefix=${CROSS} \
      --enable-static \
      --disable-opencl

    make -j8

    rm -rf ${pwd_dir}/${out_dir}; mkdir ${pwd_dir}/${out_dir}
    make install DESTDIR=${pwd_dir}/${out_dir}/
fi
