#!/bin/bash

# 系统
pwd_dir=$(cd `dirname $0`; pwd)
export http_proxy=192.168.1.5:8888
export https_proxy=192.168.1.5:8888
cmake_bin=cmake

# 工程代码
base_dir=$pwd_dir/_download
pack_url=https://github.com/opencv/opencv/archive/4.6.0/opencv-4.6.0.tar.gz
pack_file=$pwd_dir/_download/opencv-4.6.0.tar.gz
proj_dir=$pwd_dir/_download/opencv-4.6.0
build_dir=$pwd_dir/_download/opencv-4.6.0/_build
build_out=$pwd_dir/ios/opencv/
if [ ! -d "$base_dir" ]; then
    mkdir -p "$base_dir" || { echo "创建基础目录失败!"; exit 1; }
fi
if [ ! -d "$build_out" ]; then
    mkdir -p "$build_out" || { echo "创建输出目录失败!"; exit 1; }
fi
if [ ! -f "$pack_file" ]; then
    wget "$pack_url" -O "$pack_file" || { echo "下载源码失败!"; exit 1; }
fi
if [ ! -d "$proj_dir" ]; then
    tar -xvf "$pack_file" -C "$base_dir" || { echo "解压源码失败!"; exit 1; }
fi
sed -i '' -e '527s/fp\.h/math.h/' "$proj_dir"/3rdparty/libpng/pngpriv.h

# CMAKE选项
CMAKE_OPT=(
    # 系统选项
    -DCMAKE_SYSTEM_NAME=iOS
    -DCMAKE_OSX_SYSROOT=iphoneos
    -DCMAKE_OSX_ARCHITECTURES=arm64
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0
    # 库类型
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_STATIC_LIBS=ON
    -DBUILD_SHARED_LIBS=OFF
    # 功能和依赖库
    -DBUILD_opencv_world=ON
    -DBUILD_opencv_apps=OFF
    -DBUILD_opencv_java=OFF
    -DBUILD_opencv_python=OFF
    -DOPENCV_FORCE_3RDPARTY_BUILD=ON
    -DBUILD_EXAMPLES=OFF
    -DBUILD_TESTS=OFF
    -DBUILD_PERF_TESTS=OFF
    -DBUILD_DOCS=OFF
    -DBUILD_ZLIB=OFF
    -DWITH_IPP=ON
    -DOPENCV_IPP=ON
    -DENABLE_IPPICV=ON
    # 输出配置
    -DCMAKE_INSTALL_PREFIX="$build_out"
)

# 主菜单函数
main_menu() {
    clear
    echo "1 - cmake."
    echo "2 - build."
    echo "3 - clean."
    echo "x - Exit."
    echo ""
}

main_cmake() {
    if [ ! -d "$build_dir" ]; then
        mkdir -p "$build_dir" || { echo "创建编译目录失败!"; exit 1; }
    fi
    cd "$build_dir" || { echo "进入编译目录失败!"; exit 1; }
    if [ -f "CMakeCache.txt" ]; then
        rm -f CMakeCache.txt
    fi

    echo "正在cmake..."
    "$cmake_bin" -G Xcode "${CMAKE_OPT[@]}" "$proj_dir"
    if [ $? -ne 0 ]; then
        echo "cmake 配置失败!"
        cd - > /dev/null
        return 1
    fi
}

main_build() {
    if [ ! -d "$build_dir" ]; then
        echo "编译目录不存在，请先运行 cmake"
        return 1
    fi
    cd "$build_dir" || { echo "进入编译目录失败!"; exit 1; }

    echo "正在编译..."
    "$cmake_bin" --build . --config Release --parallel $(sysctl -n hw.ncpu)
    if [ $? -ne 0 ]; then
        echo "编译失败!"
        cd - > /dev/null
        return 1
    fi

    echo "正在安装..."
    if [ -d "$build_out" ]; then
        rm -rf "$build_out"
    fi
    "$cmake_bin" --install . --config Release
    if [ $? -ne 0 ]; then
        echo "安装失败!"
        cd - > /dev/null
        return 1
    fi
}

main_clean() {
    if [ -d "$build_dir" ]; then
        rm -rf "$build_dir"
        echo "已清理构建目录!"
    else
        echo "构建目录不存在，无需清理!"
    fi
}

# 主循环
while true; do
    main_menu
    read -p "请选择功能: " mainmenu
    case $mainmenu in
        1) main_cmake;;
        2) main_build;;
        3) main_clean;;
        x|X) echo "退出程序" && exit 0;;
        *) echo "" && echo "请选择一个有效的功能!";;
    esac
    echo ""
    echo "操作完成，按任意键返回主菜单!"
    read -n 1 -s -r
done