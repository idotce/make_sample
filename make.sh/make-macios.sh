#!/bin/bash

#
# by idotce (idotce@gmail.com)
#

IOSMIN="7.1";
ARCH="-arch armv7 -arch arm64";
PWDDIR=`pwd`;
BUILDDIR=".build";
OUTDIR=".out";
DESTDIR="$PWDDIR/$OUTDIR";
CUST_CONFIG="--build=x86_64-apple-darwin";
CUST_CFLAGS="";
CUST_CXXFLAGS="";
CUST_LDFLAGS="";

if [ $# != 1 ] && [ $# != 2 ] ; then
    echo "USAGE: $0 xxx.tar.gz!";
    echo "       $0 xxx.tar.gz clean!";
    exit 1;
fi

if [ ! -f $1 ] ; then
    echo "ERROR: File $1 not found!";
    exit 1;
fi

if [ "$2" == "clean" ] ; then
    rm -rf $BUILDDIR; rm -rf $OUTDIR;
    exit 0;
fi

SRCDIR=${1%.*.*};
if [ ! -d $BUILDDIR ] ; then
    mkdir $BUILDDIR;
fi
if [ ! -d $BUILDDIR/$SRCDIR ] ; then
    tar xvf $1 -C $BUILDDIR;
fi

rm -rf $OUTDIR; mkdir $OUTDIR;
cd $BUILDDIR;

SDKROOT=`xcrun --sdk iphoneos --show-sdk-path`;

CC="clang";
CXX="clang++";
LD="clang";

DEFINES="\
    -D_GNU_SOURCE \
";

INCLUDES="\
";

LIBS="\
";

CFLAGS="\
    $ARCH -miphoneos-version-min=$IOSMIN -isysroot $SDKROOT \
    -O2 -Wall -std=c99 \
    $DEFINES \
    $INCLUDES \
";

CXXFLAGS="\
    $ARCH -miphoneos-version-min=$IOSMIN -isysroot $SDKROOT \
    -O2 -Wall -std=c++11 \
    $DEFINES \
    $INCLUDES \
";

LDFLAGS="\
    $ARCH -miphoneos-version-min=$IOSMIN -isysroot $SDKROOT \
    -Wl,-segalign,4000 \
    $LIBS \
";

$SRCDIR/configure \
    $CUST_CONFIG \
    --host=arm-apple-darwin \
    CC="$CC" \
    CFLAGS="$CFLAGS $CUST_CFLAGS" \
    CXX="$CXX" \
    CXXFLAGS="$CXXFLAGS $CUST_CXXFLAGS" \
    LD="$LD" \
    LDFLAGS="$LDFLAGS $CUST_LDFLAGS" \
;

make -j4; make install DESTDIR=$DESTDIR;
cd ..;
