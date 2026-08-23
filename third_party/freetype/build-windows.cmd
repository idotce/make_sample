@echo off
chcp 65001 >nul

set pwd_dir=%~dp0
@REM 代理设置：需要时填写，留空则不启用
set "proxy="
if not "%proxy%"=="" (
    set http_proxy=%proxy%
    set https_proxy=%proxy%
)
set cmake_bin=c:\cmake\bin\cmake.exe

@REM 源码包
set base_dir=%pwd_dir%_download
set pack_url=https://mirror.accum.se/mirror/gnu.org/savannah/freetype/freetype-2.14.1.tar.xz
set pack_file=%pwd_dir%_download\freetype-2.14.1.tar.xz
set proj_dir=%pwd_dir%_download\freetype-2.14.1
set build_dir=%pwd_dir%_download\freetype-2.14.1\_build
set build_out=%pwd_dir%..\win32\freetype\
if not exist "%base_dir%" mkdir "%base_dir%"
if not exist "%pack_file%" curl -L "%pack_url%" -o "%pack_file%"
if not exist "%proj_dir%" tar -xvf "%pack_file%" -C "%base_dir%"

@REM CMAKE选项
set CMAKE_OPT= ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_STATIC_LIBS=ON ^
    -DBUILD_SHARED_LIBS=OFF ^
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
if not exist "%build_dir%" (
    mkdir "%build_dir%"
)
cd "%build_dir%"
%cmake_bin% -G "Visual Studio 16 2019" %CMAKE_OPT% %proj_dir%
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
