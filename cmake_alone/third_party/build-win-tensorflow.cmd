@echo off
chcp 65001 >nul

set pwd_dir=%~dp0
set http_proxy=192.168.1.5:8888
set https_proxy=192.168.1.5:8888
set cmake_bin=c:\cmake\bin\cmake.exe

@REM 工程代码
set base_dir=%pwd_dir%\_download
set pack_url=https://github.com/tensorflow/tensorflow/archive/refs/tags/v2.17.0.tar.gz
set pack_file=%pwd_dir%\_download\tensorflow-2.17.0.tar.gz
set proj_dir=%pwd_dir%\_download\tensorflow-2.17.0
set build_dir=%pwd_dir%\_download\tensorflow-2.17.0\_build
set build_out=%pwd_dir%\win32\tensorflow\
if not exist "%base_dir%" mkdir "%base_dir%"
if not exist "%build_out%" mkdir "%build_out%"
if not exist "%pack_file%" wget "%pack_url%" -O "%pack_file%"
if not exist "%proj_dir%" tar -xvf "%pack_file%" -C "%base_dir%"

@REM CMAKE选项
set CMAKE_OPT= ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=OFF ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_STATIC_LIBS=ON ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DTFLITE_C_BUILD_SHARED_LIBS=OFF ^
    -DTFLITE_ENABLE_GPU=ON ^
    -DTFLITE_ENABLE_XNNPACK=OFF ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=%build_out%/lib ^
    -DCMAKE_INSTALL_PREFIX=%build_out%

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
if not exist "%build_dir%" (
    mkdir "%build_dir%"
)
cd "%build_dir%"
%cmake_bin% -G "Visual Studio 16 2019" %CMAKE_OPT% %proj_dir%/tensorflow/lite/c
if %errorlevel% neq 0 (
    echo.ERROR: CMake 配置失败！
    goto PAUSE_MENU_ERROR
)
goto PAUSE_MENU

:MAIN_BUILD
cd "%build_dir%"
%cmake_bin% --build . --config Release -j20
if %errorlevel% neq 0 (
    echo.ERROR: 编译失败！
    goto PAUSE_MENU_ERROR
)
if exist "%build_out%" (
    rd /q /s "%build_out%"
)
%cmake_bin% --install . --config Release
if %errorlevel% neq 0 (
    echo.ERROR: 安装失败！
    goto PAUSE_MENU_ERROR
)
echo 安装文件...
if not exist "%build_out%/include/tensorflow" mkdir "%build_out%/include/tensorflow"
robocopy "%proj_dir%/tensorflow"             "%build_out%/include/tensorflow"   *.h       /S /E /XD .* /NFL /NDL /NJH /NJS >nul
robocopy "%build_dir%/eigen"                 "%build_out%/include"              *.h       /S /E /XD .* /NFL /NDL /NJH /NJS >nul
robocopy "%build_dir%/eigen/Eigen"           "%build_out%/include/eigen"        *         /S /E /XD .* /NFL /NDL /NJH /NJS >nul
robocopy "%build_dir%/flatbuffers/include"   "%build_out%/include"              *.h       /S /E /XD .* /NFL /NDL /NJH /NJS >nul
robocopy "%build_dir%/fp16_headers/include"  "%build_out%/include"              *.h       /S /E /XD .* /NFL /NDL /NJH /NJS >nul
robocopy "%build_dir%/gemmlowp"              "%build_out%/include"              *.h       /S /E /XD .* /NFL /NDL /NJH /NJS >nul
robocopy "%build_dir%/abseil-cpp/absl"       "%build_out%/include/absl"         *.h *.inc /S /E /XD .* /NFL /NDL /NJH /NJS >nul
goto PAUSE_MENU

:MAIN_CLEAN
if exist "%build_dir%" (
    rd /q /s "%build_dir%"
)
goto PAUSE_MENU

:PAUSE_MENU
echo.操作完成，按任意键返回主菜单!
cd %pwd_dir%
pause >nul
goto MAIN

:PAUSE_MENU_ERROR
echo.操作失败，按任意键返回主菜单!
cd %pwd_dir%
pause >nul
goto MAIN

goto :eof

:APPLY_PATCHES
echo.正在应用补丁文件...
call :APPLY_SINGLE_PATCH "%pwd_dir%\patch\lite\CMakeLists.txt"                "%proj_dir%\tensorflow\lite\CMakeLists.txt"
call :APPLY_SINGLE_PATCH "%pwd_dir%\patch\lite\operator.cc"                   "%proj_dir%\tensorflow\lite\core\c\operator.cc"
call :APPLY_SINGLE_PATCH "%pwd_dir%\patch\lite\stablehlo_reduce_window.cc"    "%proj_dir%\tensorflow\lite\kernels\stablehlo_reduce_window.cc"
REM call :APPLY_SINGLE_PATCH "%pwd_dir%\patch\lite\c\CMakeLists.txt" "%proj_dir%\tensorflow\lite\c\CMakeLists.txt"
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
