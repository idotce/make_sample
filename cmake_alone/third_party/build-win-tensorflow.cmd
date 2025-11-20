@echo off
chcp 65001 >nul

set http_proxy=192.168.1.5:8888
set https_proxy=192.168.1.5:8888

set PWD=%~dp0
set PROJ_DIR=%PWD%\_download\tensorflow
set BUILD_DIR=%PROJ_DIR%\_build
set BUILD_OUT=%PWD%\tensorflow

set CMAKE_BIN=cmake.exe
set CMAKE_GEN="Visual Studio 16 2019"
set "CMAKE_DIR=c:\cmake\bin"
set "PATH=%CMAKE_DIR%;%PATH%"

:: 确保输出目录存在
if not exist "%BUILD_OUT%" mkdir "%BUILD_OUT%"

set CMAKE_OPT= ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_STATIC_LIBS=ON ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DTFLITE_ENABLE_GPU=ON ^
    -DTFLITE_C_BUILD_SHARED_LIBS=OFF ^
    -DTFLITE_ENABLE_XNNPACK=OFF ^
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=OFF ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=%BUILD_OUT%/lib ^
    -DCMAKE_INCLUDE_OUTPUT_DIRECTORY=%BUILD_OUT%/include ^
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=%BUILD_OUT%/bin ^
    -DCMAKE_INSTALL_PREFIX=%BUILD_OUT%

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
%CMAKE_BIN% -G %CMAKE_GEN% %PROJ_DIR%\tensorflow\lite\c %CMAKE_OPT%
goto PAUSE_MENU

:MAIN_BUILD
cd "%BUILD_DIR%"
%CMAKE_BIN% --build . --config Release -j20
%CMAKE_BIN% --install . --config Release
echo 安装文件...
if not exist "%BUILD_OUT%/include/tensorflow" mkdir "%BUILD_OUT%/include/tensorflow"
robocopy "%PROJ_DIR%/tensorflow"             "%BUILD_OUT%/include/tensorflow"   *.h       /S /E /XD .* /NFL /NDL /NJH /NJS >nul
robocopy "%BUILD_DIR%/eigen"                 "%BUILD_OUT%/include"              *.h       /S /E /XD .* /NFL /NDL /NJH /NJS >nul
robocopy "%BUILD_DIR%/eigen/Eigen"           "%BUILD_OUT%/include/eigen"        *         /S /E /XD .* /NFL /NDL /NJH /NJS >nul
robocopy "%BUILD_DIR%/flatbuffers/include"   "%BUILD_OUT%/include"              *.h       /S /E /XD .* /NFL /NDL /NJH /NJS >nul
robocopy "%BUILD_DIR%/fp16_headers/include"  "%BUILD_OUT%/include"              *.h       /S /E /XD .* /NFL /NDL /NJH /NJS >nul
robocopy "%BUILD_DIR%/gemmlowp"              "%BUILD_OUT%/include"              *.h       /S /E /XD .* /NFL /NDL /NJH /NJS >nul
robocopy "%BUILD_DIR%/abseil-cpp/absl"       "%BUILD_OUT%/include/absl"         *.h *.inc /S /E /XD .* /NFL /NDL /NJH /NJS >nul
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
if not exist "%PROJ_DIR%\.git" (
    git clone -b v2.17.0 https://github.com/tensorflow/tensorflow %PROJ_DIR%
) else (
    echo 仓库已存在，跳过下载
)
goto :eof

:APPLY_PATCHES
echo.正在应用补丁文件...
call :APPLY_SINGLE_PATCH "%PWD%\patch\lite\CMakeLists.txt"                "%PROJ_DIR%\tensorflow\lite\CMakeLists.txt"
call :APPLY_SINGLE_PATCH "%PWD%\patch\lite\operator.cc"                   "%PROJ_DIR%\tensorflow\lite\core\c\operator.cc"
call :APPLY_SINGLE_PATCH "%PWD%\patch\lite\stablehlo_reduce_window.cc"    "%PROJ_DIR%\tensorflow\lite\kernels\stablehlo_reduce_window.cc"
REM call :APPLY_SINGLE_PATCH "%PWD%\patch\lite\c\CMakeLists.txt" "%PROJ_DIR%\tensorflow\lite\c\CMakeLists.txt"
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
