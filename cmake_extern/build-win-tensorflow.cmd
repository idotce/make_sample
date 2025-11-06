@echo off
chcp 65001 >nul

set PWD=%~dp0
set PROJ_DIR=%PWD%/_download/tensorflow/tensorflow/lite
set BUILD_DIR=%PWD%/_build
set PROJ_OUT=%PWD%/extern/tensorflow

set CMAKE_BIN="c:\cmake\bin\cmake.exe"
set CMAKE_GEN="Visual Studio 16 2019"

set CMAKE_OPT= ^
 -D CMAKE_BUILD_TYPE=Release ^
 -D CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
 -D BUILD_SHARED_LIBS=OFF ^
 -D TFLITE_ENABLE_GPU=ON ^
 -D XNNPACK_ENABLE_AVX512FP16=OFF ^
 -D CMAKE_CXX_STANDARD=20 ^
 -D CMAKE_CXX_STANDARD_REQUIRED=ON ^
 -D CMAKE_CXX_EXTENSIONS=OFF ^
 -D CMAKE_CXX_FLAGS="/std:c++20" ^
 -D CMAKE_C_FLAGS="/std:c++17" ^
 -D CMAKE_CXX_FLAGS_RELEASE="/MD /O2 /Ob2 /DNDEBUG" ^
 -D CMAKE_C_FLAGS_RELEASE="/MD /O2 /Ob2 /DNDEBUG" ^
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
echo n|comp patch\CMakeLists.txt _download\tensorflow\tensorflow\lite\CMakeLists.txt >nul 2>&1
if errorlevel 1 (
    copy patch\CMakeLists.txt _download\tensorflow\tensorflow\lite\CMakeLists.txt /y
)
echo n|comp patch\operator.cc _download\tensorflow\tensorflow\lite\core\c\operator.cc >nul 2>&1
if errorlevel 1 (
    copy patch\operator.cc _download\tensorflow\tensorflow\lite\core\c\operator.cc /y
)
echo n|comp patch\stablehlo_reduce_window.cc _download\tensorflow\tensorflow\lite\kernels\stablehlo_reduce_window.cc >nul 2>&1
if errorlevel 1 (
    copy patch\stablehlo_reduce_window.cc _download\tensorflow\tensorflow\lite\kernels\stablehlo_reduce_window.cc /y
)
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
