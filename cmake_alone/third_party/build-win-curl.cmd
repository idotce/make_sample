@echo off
chcp 65001 >nul

set http_proxy=192.168.1.5:8888
set https_proxy=192.168.1.5:8888

set PWD=%~dp0
set PROJ_DIR=%PWD%\curl
set BUILD_DIR=%PWD%\_build
set PROJ_OUT=%PWD%\..\extern\curl

set CMAKE_BIN=cmake.exe
set CMAKE_GEN="Visual Studio 16 2019"
set "CMAKE_DIR=c:\cmake\bin"
set "PATH=%CMAKE_DIR%;%PATH%"

:: 确保输出目录存在
if not exist "%PROJ_OUT%" mkdir "%PROJ_OUT%"

set CMAKE_OPT= ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_STATIC_LIBS=ON ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DCURL_STATIC_CRT=ON ^
    -DCURL_USE_SCHANNEL=ON ^
    -DCURL_USE_LIBPSL=OFF ^
    -DBUILD_CURL_EXE=OFF ^
    -DBUILD_TESTING=OFF ^
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
if not exist "curl\.git" (
    git clone -b curl-8_16_0  https://github.com/curl/curl
) else (
    echo 仓库已存在，跳过下载
)
goto :eof
