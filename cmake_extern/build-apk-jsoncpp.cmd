@echo off
chcp 65001 >nul

set PWD=%~dp0
set PROJ_DIR=%PWD%/_download/jsoncpp
set BUILD_DIR=%PWD%/_build
set PROJ_OUT=%PWD%/extern_apk/jsoncpp

set CMAKE_BIN="cmake.exe"
set CMAKE_GEN="Ninja"
set CMAKE_DIR="d:\Documents\Android\Sdk\cmake\3.18.1\bin"
set NDK_DIR="d:\Documents\Android\Sdk\ndk\21.0.6113669"
set PATH=%CMAKE_DIR%;%PATH%

set CMAKE_OPT= ^
 -D CMAKE_TOOLCHAIN_FILE=%NDK_DIR%/build/cmake/android.toolchain.cmake ^
 -D CMAKE_MAKE_PROGRAM=ninja ^
 -D ANDROID_ABI=arm64-v8a ^
 -D ANDROID_PLATFORM=android-21 ^
 -D CMAKE_BUILD_TYPE=Release ^
 -D BUILD_STATIC_LIBS=ON ^
 -D BUILD_SHARED_LIBS=OFF ^
 -D JSONCPP_WITH_TESTS=OFF ^
 -D JSONCPP_STATIC_WINDOWS_RUNTIME=ON ^
 -D CMAKE_INSTALL_PREFIX=%PROJ_OUT%

:MAIN
cls
echo. 1 - cmake.
echo. 2 - build.
echo. 3 - clean.
echo. x - Exit.
echo.

:MENU
set /p mainmenu=请选择功能:
if '%mainmenu%'=='1' (goto MAIN_CMAKE)
if '%mainmenu%'=='2' (goto MAIN_BUILD)
if '%mainmenu%'=='3' (goto MAIN_CLEAN)
if '%mainmenu%'=='x' exit /b
echo.
echo.请选择一个有效的功能,按任意键返回!
pause
goto MAIN

:MAIN_CMAKE
if not exist %BUILD_DIR% (
    mkdir "%BUILD_DIR%"
)
cd "%BUILD_DIR%"
%CMAKE_BIN% -G %CMAKE_GEN% %PROJ_DIR% %CMAKE_OPT%
goto PAUSE_MENU

:MAIN_BUILD
cd "%BUILD_DIR%"
%CMAKE_BIN% --build . --config Release --target install
goto PAUSE_MENU

:MAIN_CLEAN
rd /q /s "%BUILD_DIR%"
goto PAUSE_MENU

:PAUSE_MENU
echo.操作完成，按任意键返回主菜单!
cd %PWD%
pause >nul
goto MAIN
