#!/bin/bash

set -e

NDK_DIR="/mnt/d/Documents/Android/android-ndk-r27d"
ANDROID_API=21
OPENSSL_VERSION="1.1.1t"
BUILD_DIR="openssl_apk"

echo "=== 构建 OpenSSL $OPENSSL_VERSION for Android ==="

# 检查NDK目录
if [ ! -d "$NDK_DIR" ]; then
    echo "❌ 错误: NDK目录不存在 - $NDK_DIR"
    exit 1
fi

# 清理并创建构建目录
echo "设置构建目录..."
if [ -d "$BUILD_DIR" ]; then
    echo "清理现有构建目录..."
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR/include/openssl"
mkdir -p "$BUILD_DIR/lib"
mkdir -p "$BUILD_DIR/bin"
mkdir -p "$BUILD_DIR/ssl"
mkdir -p "$BUILD_DIR/openssl"

export ANDROID_NDK_HOME="$NDK_DIR"
TOOLCHAIN="$NDK_DIR/toolchains/llvm/prebuilt/linux-x86_64"

# 检查工具链
if [ ! -d "$TOOLCHAIN" ]; then
    echo "❌ 错误: 工具链目录不存在 - $TOOLCHAIN"
    exit 1
fi

export PATH="$TOOLCHAIN/bin:$PATH"

# 检查OpenSSL源码
if [ ! -d "openssl-$OPENSSL_VERSION" ]; then
    echo "❌ 错误: OpenSSL源码目录不存在"
    echo "请先下载并解压 openssl-$OPENSSL_VERSION.tar.gz"
    exit 1
fi

cd "openssl-$OPENSSL_VERSION"

# 设置编译器
export CC="$TOOLCHAIN/bin/aarch64-linux-android$ANDROID_API-clang"
export CXX="$TOOLCHAIN/bin/aarch64-linux-android$ANDROID_API-clang++"
export AR="$TOOLCHAIN/bin/llvm-ar"
export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"

export CFLAGS="-target aarch64-linux-android -march=armv8-a -mno-outline-atomics -DOPENSSL_NO_ASM"
#export LDFLAGS="-latomic"  # 提前链接原子库

echo "编译环境:"
echo "  CC: $CC"
echo "  AR: $AR"
echo "  CFLAGS: $CFLAGS"

# 清理
echo "清理之前的构建..."
make clean 2>/dev/null || true

# 配置
echo "配置 OpenSSL..."
./Configure android-arm64 \
    -D__ANDROID_API__=$ANDROID_API \
    --prefix="$(pwd)/../$BUILD_DIR" \
    --openssldir="$(pwd)/../$BUILD_DIR/ssl" \
    no-shared \
    no-tests \
    no-asm

# 构建库
echo "构建 OpenSSL 库..."
if ! make build_libs -j$(nproc); then
    echo "❌ 构建库失败"
    exit 1
fi

# 安装头文件
echo "安装头文件..."
if [ -d "include/openssl" ]; then
    cp -r include/openssl/* "../$BUILD_DIR/include/openssl/"
    echo "✅ 头文件安装完成"
else
    echo "❌ 错误: include/openssl 目录不存在"
    exit 1
fi

# 安装库文件
echo "安装库文件..."
if [ -f "libssl.a" ]; then
    cp libssl.a "../$BUILD_DIR/lib/"
    echo "✅ libssl.a 安装完成"
else
    echo "❌ 错误: libssl.a 未找到"
    exit 1
fi

if [ -f "libcrypto.a" ]; then
    cp libcrypto.a "../$BUILD_DIR/lib/"
    echo "✅ libcrypto.a 安装完成"
else
    echo "❌ 错误: libcrypto.a 未找到"
    exit 1
fi

# 创建必要的符号链接
cd "../$BUILD_DIR"
if [ ! -f "lib/libssl.so" ] && [ -f "lib/libssl.a" ]; then
    ln -sf libssl.a lib/libssl.so 2>/dev/null || true
fi
if [ ! -f "lib/libcrypto.so" ] && [ -f "lib/libcrypto.a" ]; then
    ln -sf libcrypto.a lib/libcrypto.so 2>/dev/null || true
fi

echo ""
echo "🎉 OpenSSL 构建成功!"
echo ""
echo "📁 构建结果:"
echo "  头文件: $PWD/include/"
echo "  库文件: $PWD/lib/"
echo "  SSL配置: $PWD/ssl/"
echo ""

echo ""
echo "🔍 验证库文件:"
file lib/libssl.a
file lib/libcrypto.a

echo ""
echo "✅ 所有步骤完成! OpenSSL 已成功构建 for Android ARM64"
