#!/bin/bash

set -e

# ========== 仅替换Android NDK配置为iOS SDK配置 ==========
# iOS最低版本（按需调整）
MIN_IOS_VERSION="12.0"
# OpenSSL版本和原脚本保持一致
OPENSSL_VERSION="1.1.1t"
# 构建目录仅改标识，逻辑不变
BUILD_DIR="openssl_ios"

echo "=== 构建 OpenSSL $OPENSSL_VERSION for iOS ARM64 ==="

# ========== 替换NDK检查为iOS SDK检查 ==========
IOS_SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)
if [ ! -d "$IOS_SDK_PATH" ]; then
    echo "❌ 错误: iOS SDK目录不存在 - $IOS_SDK_PATH"
    echo "请先安装Xcode并执行: xcode-select --install"
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

# 检查OpenSSL源码
if [ ! -d "openssl-$OPENSSL_VERSION" ]; then
    echo "❌ 错误: OpenSSL源码目录不存在"
    echo "请先下载并解压 openssl-$OPENSSL_VERSION.tar.gz"
    exit 1
fi

cd "openssl-$OPENSSL_VERSION"

# ========== 替换Android工具链为iOS Clang ==========
export CC=$(xcrun --sdk iphoneos -find clang)
export CXX=$(xcrun --sdk iphoneos -find clang++)
export AR=$(xcrun --sdk iphoneos -find ar)
export RANLIB=$(xcrun --sdk iphoneos -find ranlib)
export PATH="$TOOLCHAIN/bin:$PATH"  # 保留原PATH逻辑，无影响

# ========== 修复核心：iOS专属CFLAGS（解决编译失败关键） ==========
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

# ========== 清理（复用原逻辑） ==========
echo "清理之前的构建..."
make clean 2>/dev/null || true
rm -f config.cache  # 新增：清理配置缓存（解决重复编译报错）

# ========== 修复核心：OpenSSL iOS配置命令 ==========
echo "配置 OpenSSL..."
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

# ========== 构建库（替换nproc为macOS兼容命令） ==========
echo "构建 OpenSSL 库..."
if ! make build_libs -j$(sysctl -n hw.ncpu); then
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
echo "✅ 所有步骤完成! OpenSSL 已成功构建 for iOS ARM64"