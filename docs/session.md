# session

### 2026-08-23 20:00 - make_sample 仓库全面重构整理

# 需求
用户要求对该参考示例仓库（CMake/Makefile/第三方库编译脚本）做完全重构归类整理，同时修正错误。约束：不做公共模板，每个脚本必须独立可用（供其他项目拷贝参考）；硬编码代理参数化；授权删除 `_backup/` 和二进制文件（wget.exe、*.tar.gz、.bak）。
追加：_notes/ 下两个工具链备忘并入根 _note.txt，删除 _notes/ 目录。

# 结论
## 新目录结构
```
_note.txt            根目录总览说明 + 工具链备忘（MSVC 版本对照、Linaro 下载、Android 运行；原 _notes/ 内容已并入）
cmake/
  sample|library|mfc           原 CMake 示例
  app-thirdparty/              原 cmake_alone/sample（链接第三方库的完整示例）
makefile/                      原样保留 + 小修
third_party/<库名>/            按库归类：curl jsoncpp opencv tensorflow freetype glew
                               ffmpeg x264 ncurses minicom lrzsz file（build-linux-aarch64.sh）
  libnet-ios/ ios-generic/ opencv-arm/ patch/
```
脚本统一命名 build-{windows,macos,ios,android}.cmd/.sh；CMake 库输出约定 third_party/{win32,macos,ios,apk}/<lib>/；交叉编译库输出 third_party/_install/aarch64/。

## 已删除（用户授权）
_backup/ 整目录、wget.exe、patch/openssl-1.1.1t.tar.gz、port/libnet_ios/libnet-1.1.6.tar.gz、lite/CMakeLists.txt.bak；合并后删除 cmake_alone/、port/ 及各子 .gitignore。

## 修正的错误
1. port 系（现 third_party/*/build-linux-aarch64.sh）：main_build 里误调 `cmake --install`（autotools 工程必失败）→ 删除，只保留 `make install DESTDIR=`；菜单文案 cmake→configure。
2. patch/build-apk-openssl.sh：CRLF 换行导致 bash 语法错误（unexpected end of file）→ 转 LF，bash -n 通过。
3. cmake/library/lib/CMakeLists.txt：残留 MFC 配置（CMAKE_MFC_FLAG/_AFXDLL）→ 移除；install 分支简化为 RUNTIME/LIBRARY/ARCHIVE 一条。
4. cmake/library/CMakeLists.txt：`link_directories(lib/_msys)` 指向不存在目录 → 改为 LIBTEST_ROOT=lib/_install（与 lib 安装路径一致）。
5. cmake/app-thirdparty/CMakeLists.txt：依赖 CMake 不原生定义的 MACOS/IOS 变量，直接 macos 构建时 THIRD_PARTY_DIR 为空 → 改用 APPLE+CMAKE_SYSTEM_NAME 判断并自行 set(MACOS/IOS)；路径 ../third_party→../../third_party；删除 /MT 与 CMAKE_MSVC_RUNTIME_LIBRARY 双重设置（cmake/sample 同样处理）；utf-8 判断条件冗余简化。
6. 各 cmd 脚本：下载由 wget（已删 wget.exe）改 curl -L（Win10+ 自带）；统一补 errorlevel 错误分支；删除末尾不可达 goto :eof。
7. makefile：Windows_NT 分支 `mkdir -p` 与 `rmdir /s /q` 混用（cmd 下前者失败、sh 下后者失败）→ 统一 mkdir -p/rm -rf 并注明需 MSYS/MinGW 环境。
8. cmake/build-macos.sh --parallel 20 → $(sysctl -n hw.ncpu)；删除无效变量 CMAKE_INCLUDE_OUTPUT_DIRECTORY（CMake 无此变量）。
9. tensorflow 脚本补丁逻辑统一为 apply_patch 函数（cmp 比较、覆盖前备份），mac/ios 也应用全部 3 个补丁。

## 其他改动
- 所有脚本代理参数化为头部 `proxy=""` 变量（含 opencv-arm 的 192.168.1.10）。
- 根 .gitignore 补全（_build/_install/_download/out/build、编辑器、对象文件）。
- 笔记合并：cmake_alone/_note.txt + port/_note.txt → third_party/_note.txt。

## 验证
- 全部 *.sh 通过 `bash -n`。
- makefile 实测 macOS 编译运行通过（out/base 输出正常）。
- cmake configure 实测：sample、library、library/lib 三个工程配置成功（仅 configure，未做完整编译）。
- 未验证：各第三方库脚本的实际编译（需对应平台/工具链）、cmd 脚本（Windows 环境）、iOS/macOS 库构建。
