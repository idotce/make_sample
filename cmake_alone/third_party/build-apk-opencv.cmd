@echo off
chcp 65001 >nul

set http_proxy=192.168.1.5:8888
set https_proxy=192.168.1.5:8888

set PWD=%~dp0
set PROJ_DIR=%PWD%\opencv
set BUILD_DIR=%PWD%\_build
set PROJ_OUT=%PWD%\..\extern\opencv

set CMAKE_BIN=cmake.exe
set CMAKE_GEN=Ninja
set "CMAKE_DIR=d:\Documents\Android\Sdk\cmake\3.18.1\bin"
set "NDK_DIR=d:\Documents\Android\Sdk\ndk\21.0.6113669"
set "PATH=%CMAKE_DIR%;%PATH%"

:: 确保输出目录存在
if not exist "%PROJ_OUT%" mkdir "%PROJ_OUT%"

set CMAKE_OPT= ^
    -DCMAKE_TOOLCHAIN_FILE=%NDK_DIR%\build\cmake\android.toolchain.cmake ^
    -DCMAKE_MAKE_PROGRAM=ninja ^
    -DANDROID_ABI=arm64-v8a ^
    -DANDROID_PLATFORM=android-21 ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_JAVA=OFF ^
    -DBUILD_FAT_JAVA_LIB=OFF ^
    -DBUILD_ANDROID_SERVICE=OFF ^
    -DBUILD_ANDROID_EXAMPLES=OFF ^
    -DBUILD_ANDROID_PROJECTS=OFF ^
    -DBUILD_STATIC_LIBS=ON ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DBUILD_opencv_world=ON ^
    -DOPENCV_FORCE_3RDPARTY_BUILD=ON ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_TESTS=OFF ^
    -DBUILD_PERF_TESTS=OFF ^
    -DBUILD_DOCS=OFF ^
    -DWITH_IPP=ON ^
    -DOPENCV_IPP=ON ^
    -DENABLE_IPPICV=ON ^
    -DBUILD_opencv_java=OFF ^
    -DBUILD_opencv_python=OFF ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=%PROJ_OUT%/lib ^
    -DCMAKE_INCLUDE_OUTPUT_DIRECTORY=%PROJ_OUT%/include ^
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=%PROJ_OUT%/bin ^
    -DCMAKE_INSTALL_PREFIX=%PROJ_OUT%

:MAIN
cls
echo. 1 - cmake.
echo. 2 - build.
echo. 3 - clean.
echo. x - Exit.
echo.

:MENU
set /p mainmenu=请选择功能:
if "%mainmenu%"=="1" (goto MAIN_CMAKE)
if "%mainmenu%"=="2" (goto MAIN_BUILD)
if "%mainmenu%"=="3" (goto MAIN_CLEAN)
if "%mainmenu%"=="x" exit /b
echo.
echo.请选择一个有效的功能,按任意键返回!
pause
goto MAIN

:MAIN_CMAKE
call :APPLY_DOWNLOADS
if not exist "%BUILD_DIR%" (
    mkdir "%BUILD_DIR%"
)
cd "%BUILD_DIR%"
%CMAKE_BIN% -G %CMAKE_GEN% %PROJ_DIR% %CMAKE_OPT%
goto PAUSE_MENU

:MAIN_BUILD
cd "%BUILD_DIR%"
%CMAKE_BIN% --build . --config Release -j20
%CMAKE_BIN% --install . --config Release
goto PAUSE_MENU

:MAIN_CLEAN
if exist "%BUILD_DIR%" (
    rd /q /s "%BUILD_DIR%"
)
goto PAUSE_MENU

:PAUSE_MENU
echo.操作完成，按任意键返回主菜单!
cd %PWD%
pause >nul
goto MAIN

:APPLY_DOWNLOADS
if not exist "opencv\.git" (
    git clone --branch 4.6.0 https://github.com/opencv/opencv
) else (
    echo 仓库已存在，跳过下载
)
goto :eof
