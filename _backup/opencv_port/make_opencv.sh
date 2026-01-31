#!/bin/bash

#
# by idotce (idotce@gmail.com)
#

#CROSS=arm-linux-gnueabi-
CROSS=arm-himix200-linux-

pwd_dir=$(cd `dirname $0`; pwd)
echo ${pwd_dir}

gz_url=https://github.com/opencv/opencv/archive/3.4.2.tar.gz
gz_file=opencv-3.4.2.tar.gz
code_dir=opencv-3.4.2

build_dir="_build"
out_dir="_out"

export http_proxy=http://192.168.1.10:8888
export https_proxy=http://192.168.1.10:8888

if [ ! -f $gz_file ]; then
    wget $gz_url -O $gz_file
fi

if [ ! -d $code_dir ]; then
    tar -xzvf $gz_file
fi

if [ -d $code_dir ]; then
    cd $code_dir; rm -rf $build_dir; mkdir $build_dir; cd $build_dir

    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DBUILD_ZLIB=ON \
      -DWITH_CUDA=OFF \
      -DWITH_CUFFT=OFF \
      -DWITH_CUBLAS=OFF \
      -DWITH_NVCUVID=OFF \
      -DWITH_GTK=OFF \
      -DWITH_GTK_2_X=OFF \
      -DWITH_IPP=OFF \
      -DWITH_QT=OFF \
      -DWITH_ITT=OFF \
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_TOOLCHAIN_FILE=../../toolchain.cmake

    make -j8

    rm -rf ${pwd_dir}/${out_dir}; mkdir ${pwd_dir}/${out_dir}
    make install DESTDIR=${pwd_dir}/${out_dir}/
fi
