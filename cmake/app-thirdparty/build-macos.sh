#!/bin/bash

# 系统
pwd_dir=$(cd `dirname $0`; pwd)
# 代理设置：需要时填写，留空则不启用
proxy=""
if [ -n "$proxy" ]; then
    export http_proxy=$proxy
    export https_proxy=$proxy
fi
cmake_bin=cmake

# 工程代码
base_dir=$pwd_dir
proj_dir=$pwd_dir
build_dir=$pwd_dir/_build
build_out=$pwd_dir/_install
if [ ! -d "$base_dir" ]; then
    mkdir -p "$base_dir" || { echo "创建基础目录失败!"; exit 1; }
fi
if [ ! -d "$build_out" ]; then
    mkdir -p "$build_out" || { echo "创建输出目录失败!"; exit 1; }
fi

# CMAKE选项
CMAKE_OPT=(
    # 系统选项
    -DCMAKE_SYSTEM_NAME=Darwin
    -DCMAKE_OSX_SYSROOT=macosx
    -DCMAKE_OSX_ARCHITECTURES=arm64
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0
    # 库类型
    -DCMAKE_BUILD_TYPE=Release
    # 功能和依赖库
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
    "$cmake_bin" "${CMAKE_OPT[@]}" "$proj_dir"
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
