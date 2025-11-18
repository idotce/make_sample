@echo off
chcp 65001 >nul

set http_proxy=192.168.1.5:8888
set https_proxy=192.168.1.5:8888

set PWD=%~dp0
set PROJ_DIR=%PWD%\tensorflow\tensorflow\lite\c
set BUILD_DIR=%PWD%\_build
set PROJ_OUT=%PWD%\..\extern\tensorflow

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
    -DTFLITE_ENABLE_GPU=ON ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DTFLITE_C_BUILD_SHARED_LIBS=OFF ^
    -DTFLITE_ENABLE_XNNPACK=OFF ^
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
call :APPLY_PATCHES
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
echo 安装文件...
if not exist "%PROJ_OUT%/include/tensorflow" mkdir "%PROJ_OUT%/include/tensorflow"
robocopy "%PROJ_DIR%/../.." "%PROJ_OUT%/include/tensorflow" *.h /S /E /NFL /NDL /NJH /NJS >nul
robocopy "%BUILD_DIR%/eigen" "%PROJ_OUT%/include" * /S /E /XD .* /NFL /NDL /NJH /NJS >nul
robocopy "%BUILD_DIR%/flatbuffers/include" "%PROJ_OUT%/include" *.h /S /E /NFL /NDL /NJH /NJS >nul
robocopy "%BUILD_DIR%/fp16_headers/include" "%PROJ_OUT%/include" *.h /S /E /NFL /NDL /NJH /NJS >nul
robocopy "%BUILD_DIR%/gemmlowp" "%PROJ_OUT%/include" *.h /S /E /XD .* /NFL /NDL /NJH /NJS >nul
robocopy "%BUILD_DIR%/abseil-cpp/absl" "%PROJ_OUT%/include/absl" *.h *.inc /S /E /NFL /NDL /NJH /NJS >nul
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
if not exist "tensorflow\.git" (
    git clone -b v2.17.0 https://github.com/tensorflow/tensorflow
) else (
    echo 仓库已存在，跳过下载
)
goto :eof

:APPLY_PATCHES
echo.正在应用补丁文件...
REM call :APPLY_SINGLE_PATCH "%PWD%\..\patch\lite\CMakeLists.txt" "%PWD%\tensorflow\tensorflow\lite\CMakeLists.txt"
call :APPLY_SINGLE_PATCH "%PWD%\..\patch\lite\operator.cc" "%PWD%\tensorflow\tensorflow\lite\core\c\operator.cc"
call :APPLY_SINGLE_PATCH "%PWD%\..\patch\lite\stablehlo_reduce_window.cc" "%PWD%\tensorflow\tensorflow\lite\kernels\stablehlo_reduce_window.cc"
REM call :APPLY_SINGLE_PATCH "%PWD%\..\patch\lite\c\CMakeLists.txt" "%PWD%\tensorflow\tensorflow\lite\c\CMakeLists.txt"
echo.补丁应用完成!
goto :eof

:APPLY_SINGLE_PATCH
setlocal disabledelayedexpansion
set PATCH_SRC=%~1
set PATCH_DEST=%~2

echo n|comp "%PATCH_SRC%" "%PATCH_DEST%" >nul 2>&1
if errorlevel 1 (
    echo 复制补丁: %PATCH_SRC%
    copy "%PATCH_DEST%" "%PATCH_DEST%.backup" /y >nul
    copy "%PATCH_SRC%" "%PATCH_DEST%" /y >nul
) else (
    echo 文件最新: %PATCH_SRC%
)
endlocal
goto :eof
