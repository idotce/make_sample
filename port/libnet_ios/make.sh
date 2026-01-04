#!/bin/bash

#
# by idotce (idotce@gmail.com)
#
# https://ares.lids.mit.edu/redmine/projects/forest-game/wiki/Building_sigc++_for_iOS
# https://gist.github.com/idotce/be94b667b40ed694d006
#
# xcode-select --install
#
# "/Applications/Xcode.app/Contents/Developer"
# "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer"
# "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
#

IOSMIN="7.0";
PWDDIR=`pwd`;
BUILDDIR="build";
OUTDIR="out";
PREFIX="$PWDDIR/$OUTDIR/usr";
CUST_CONFIG="ENDIANESS=LIBNET_LIL_ENDIAN ac_cv_libnet_endianess=lil ac_libnet_have_packet_socket=no ac_cv_libnet_linux_procfs=no ac_cv_lbl_unaligned_fail=no";
CUST_CFLAGS="";
CUST_CXXFLAGS="";
CUST_LDFLAGS="";

if [ $# != 1 ] ; then
    echo "USAGE: $0 file(tar.gz code file)!";
    exit 1;
fi

if [ ! -f $1 ] ; then
    echo "ERROR: File $1 not found!";
    exit 1;
fi

rm -rf $BUILDDIR; mkdir $BUILDDIR;
rm -rf $OUTDIR; mkdir $OUTDIR;
rm -rf $PREFIX; mkdir -p $PREFIX;
tar xvf $1;
cd $BUILDDIR;

DEVROOT=`xcode-select -p`;
SDKROOT=`xcrun --sdk iphoneos --show-sdk-path`;
BINROOT="$DEVROOT/usr/bin";

ARCH="-arch armv7 -arch armv7s -arch arm64";

INCLUDES="\
    -I$SDKROOT/usr/include \
    -I$PWDDIR/$BUILDDIR/include \
";

LIBS="\
    -L$SDKROOT/usr/lib \
    -L$SDKROOT/usr/lib/system \
";

CFLAGS="\
    $ARCH \
    -isysroot ${SDKROOT} \
    -miphoneos-version-min=$IOSMIN \
    -g -O2 -Wall -std=c99 \
    ${INCLUDES} \
";

CXXFLAGS="\
    $ARCH \
    -isysroot ${SDKROOT} \
    -miphoneos-version-min=$IOSMIN \
    -g -O2 -Wall -std=c++11 \
    ${INCLUDES} \
";

LDFLAGS="\
    $ARCH \
    -isysroot ${SDKROOT} \
    -miphoneos-version-min=$IOSMIN \
    -Wl,-segalign,4000 \
    ${LIBS} \
";

CC="${BINROOT}/gcc";
CXX="${BINROOT}/g++";

make distclean;

../${1%.*.*}/configure \
    $CUST_CONFIG \
    --prefix="$PREFIX" \
    --host=arm-apple-darwin \
    CC="$CC" \
    CFLAGS="$CFLAGS $CUST_CFLAGS" \
    CXX="$CXX" \
    CXXFLAGS="$CXXFLAGS $CUST_CXXFLAGS" \
    LDFLAGS="$LDFLAGS $CUST_LDFLAGS" \
;

mkdir -p include/netinet;
cp `xcrun --sdk iphonesimulator --show-sdk-path`/usr/include/netinet/udp.h \
    include/netinet/ \
;

make -j4; make install;
cd ..;
