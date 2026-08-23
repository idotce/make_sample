#!/bin/bash

set -e

MIN_IOS_VERSION="12.0"
BUILD_VERSION="1.1.1t"
BUILD_NAME="openssl"
BUILD_DIR="openssl_ios"

echo "=== 构建 $BUILD_DIR $BUILD_VERSION ==="

IOS_SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)
if [ ! -d "$IOS_SDK_PATH" ]; then
    echo "❌ 错误: iOS SDK目录不存在 - $IOS_SDK_PATH"
    echo "请先安装Xcode并执行: xcode-select --install"
    exit 1
fi

echo "设置构建目录..."
if [ -d "$BUILD_DIR" ]; then
    echo "清理现有构建目录..."
    rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR/include"
mkdir -p "$BUILD_DIR/lib"
mkdir -p "$BUILD_DIR/bin"

if [ ! -d "$BUILD_NAME-$BUILD_VERSION" ]; then
    echo "❌ 错误: 源码目录不存在"
    echo "请先下载并解压 $BUILD_NAME-$BUILD_VERSION.tar.gz"
    exit 1
fi

cd "$BUILD_NAME-$BUILD_VERSION"

export CC=$(xcrun --sdk iphoneos -find clang)
export CXX=$(xcrun --sdk iphoneos -find clang++)
export AR=$(xcrun --sdk iphoneos -find ar)
export RANLIB=$(xcrun --sdk iphoneos -find ranlib)

export CFLAGS="-arch arm64 \
    -isysroot $IOS_SDK_PATH \
    -miphoneos-version-min=$MIN_IOS_VERSION \
    -fembed-bitcode \
    -O2 \
    -DNDEBUG \
    -DOPENSSL_NO_ASM \
    -DOPENSSL_THREADS \
    -DOPENSSL_NO_SECURE_MEMORY \
    -D__APPLE_USE_RFC_3542"

echo "清理之前的构建..."
make clean 2>/dev/null || true
rm -f config.cache
rm -rf autom4te.cache 2>/dev/null || true

echo "配置..."
./Configure iphoneos-cross \
    --prefix="$(pwd)/../$BUILD_DIR" \
    --openssldir="$(pwd)/../$BUILD_DIR/ssl" \
    no-shared \
    no-tests \
    no-asm \
    no-hw \
    no-engine \
    -isysroot $IOS_SDK_PATH \
    -miphoneos-version-min=$MIN_IOS_VERSION

echo "构建..."
if ! make -j$(sysctl -n hw.ncpu); then
    echo "❌ 构建库失败"
    exit 1
fi
make install

echo ""
echo "🎉 构建成功!"
echo ""
echo "📁 构建结果:"
echo "  头文件: $(pwd)/../$BUILD_DIR/include/"
echo "  库文件: $(pwd)/../$BUILD_DIR/lib/"
echo ""

echo "✅ 所有步骤完成!"
