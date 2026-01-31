@echo off
chcp 65001 >nul

set pwd_dir=%~dp0
set http_proxy=192.168.1.5:8888
set https_proxy=192.168.1.5:8888
set cmake_bin=c:\cmake\bin\cmake.exe

@REM 工程代码
set base_dir=%pwd_dir%\_download
set pack_url=https://codeload.github.com/Perlmint/glew-cmake/zip/refs/heads/master
set pack_file=%pwd_dir%\_download\glew-cmake-master.zip
set proj_dir=%pwd_dir%\_download\glew-cmake-master
set build_dir=%pwd_dir%\_download\glew-cmake-master\_build
set build_out=%pwd_dir%\win32\glew\
if not exist "%base_dir%" mkdir "%base_dir%"
if not exist "%build_out%" mkdir "%build_out%"
if not exist "%pack_file%" wget "%pack_url%" -O "%pack_file%"
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

goto :eof
