@echo off
chcp 65001 >nul

set PWD=%~dp0
set PROJ_DIR=%PWD%/_download/tensorflow/tensorflow/lite/c
set BUILD_DIR=%PWD%/_build
set PROJ_OUT=%PWD%/extern_apk/tensorflow

set CMAKE_BIN=cmake.exe
set CMAKE_GEN=Ninja
set "CMAKE_DIR=d:\Documents\Android\Sdk\cmake\3.18.1\bin"
set "NDK_DIR=d:\Documents\Android\Sdk\ndk\21.0.6113669"
set "PATH=%CMAKE_DIR%;%PATH%"

:: 确保输出目录存在
if not exist "%PROJ_OUT%" mkdir "%PROJ_OUT%"

set CMAKE_OPT= ^
 -D CMAKE_TOOLCHAIN_FILE=%NDK_DIR%\build\cmake\android.toolchain.cmake ^
 -D CMAKE_MAKE_PROGRAM=ninja ^
 -D ANDROID_ABI=arm64-v8a ^
 -D ANDROID_PLATFORM=android-21 ^
 -D CMAKE_BUILD_TYPE=Release ^
 -D TFLITE_ENABLE_GPU=ON ^
 -D BUILD_SHARED_LIBS=OFF ^
 -D TFLITE_C_BUILD_SHARED_LIBS=OFF ^
 -D CMAKE_ARCHIVE_OUTPUT_DIRECTORY=%PROJ_OUT%/lib ^
 -D CMAKE_LIBRARY_OUTPUT_DIRECTORY=%PROJ_OUT%/lib ^
 -D CMAKE_RUNTIME_OUTPUT_DIRECTORY=%PROJ_OUT%/bin ^
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
if "%mainmenu%"=="1" (goto MAIN_CMAKE)
if "%mainmenu%"=="2" (goto MAIN_BUILD)
if "%mainmenu%"=="3" (goto MAIN_CLEAN)
if "%mainmenu%"=="x" exit /b
echo.
echo.请选择一个有效的功能,按任意键返回!
pause
goto MAIN

:MAIN_CMAKE
call :APPLY_PATCHES
if not exist "%BUILD_DIR%" (
    mkdir "%BUILD_DIR%"
)
set http_proxy=192.168.1.5:8888
set https_proxy=192.168.1.5:8888
cd "%BUILD_DIR%"
%CMAKE_BIN% -G %CMAKE_GEN% %PROJ_DIR% %CMAKE_OPT%
goto PAUSE_MENU

:MAIN_BUILD
cd "%BUILD_DIR%"
%CMAKE_BIN% --build . --config Release --target install -j16
echo 安装文件...
if not exist "%PROJ_OUT%/include/tensorflow" mkdir "%PROJ_OUT%/include/tensorflow"
robocopy "%PROJ_DIR%/../.." "%PROJ_OUT%/include/tensorflow" *.h /S /E /NFL /NDL /NJH /NJS >nul
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

:APPLY_PATCHES
echo.正在应用补丁文件...
call :APPLY_SINGLE_PATCH "patch\lite\CMakeLists.txt" "_download\tensorflow\tensorflow\lite\CMakeLists.txt"
call :APPLY_SINGLE_PATCH "patch\lite\operator.cc" "_download\tensorflow\tensorflow\lite\core\c\operator.cc"
call :APPLY_SINGLE_PATCH "patch\lite\stablehlo_reduce_window.cc" "_download\tensorflow\tensorflow\lite\kernels\stablehlo_reduce_window.cc"
call :APPLY_SINGLE_PATCH "patch\lite\c\CMakeLists.txt" "_download\tensorflow\tensorflow\lite\c\CMakeLists.txt"
echo.补丁应用完成!
goto :eof

:APPLY_SINGLE_PATCH
setlocal disabledelayedexpansion
set PATCH_SRC=%~1
set PATCH_DEST=%~2

echo n|comp "%PATCH_SRC%" "%PATCH_DEST%" >nul 2>&1
if errorlevel 1 (
    echo 复制补丁: %PATCH_SRC%
    copy "%PATCH_SRC%" "%PATCH_DEST%" /y >nul
) else (
    echo 文件最新: %PATCH_SRC%
)
endlocal
goto :eof
