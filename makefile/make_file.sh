#!/bin/bash

#
# by idotce (idotce@gmail.com)
#

#CROSS=arm-linux-gnueabi-
CROSS=arm-himix200-linux-

pwd_dir=$(cd `dirname $0`; pwd)
echo ${pwd_dir}

gz_url=ftp://ftp.astron.com/pub/file/file-5.32.tar.gz
gz_file=file-5.32.tar.gz
code_dir=file-5.32

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

    ../configure \
      CC=${CROSS}gcc \
      AR=${CROSS}ar \
      --host=arm-linux \
      --enable-static \
      --disable-shared

    make -j8

    rm -rf ${pwd_dir}/${out_dir}; mkdir ${pwd_dir}/${out_dir}
    make install DESTDIR=${pwd_dir}/${out_dir}/
fi
