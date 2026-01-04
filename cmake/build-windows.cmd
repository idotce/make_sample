@echo off
chcp 65001 >nul

set pwd_dir=%~dp0
set http_proxy=192.168.1.5:8888
set https_proxy=192.168.1.5:8888
set cmake_bin=c:\cmake\bin\cmake.exe

@REM 工程代码
set base_dir=%pwd_dir%
set proj_dir=%pwd_dir%
set build_dir=%pwd_dir%\_build
set build_out=%pwd_dir%\_install
if not exist "%base_dir%" mkdir "%base_dir%"
if not exist "%build_out%" mkdir "%build_out%"

@REM CMAKE选项
set CMAKE_OPT= ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%build_out% ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=%build_out%/lib ^
    -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=%build_out%/lib ^
    -DCMAKE_INCLUDE_OUTPUT_DIRECTORY=%build_out%/include ^
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=%build_out%/bin

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
%cmake_bin% -G "Visual Studio 16 2019" %proj_dir% %CMAKE_OPT%
goto PAUSE_MENU

:MAIN_BUILD
cd "%build_dir%"
%cmake_bin% --build . --config Release -j20
%cmake_bin% --install . --config Release
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

goto :eof
