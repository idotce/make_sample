@echo off
chcp 65001

SET PROJ_DIR=%~dp0
SET BUILD_DIR=%PROJ_DIR%\_build
SET BUILD_BIN=%PROJ_DIR%\_install
SET CMAKE_BIN="c:\cmake\bin\cmake.exe"

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
if '%mainmenu%'=='x' exit
echo.
echo.请选择一个有效的功能,按任意键返回!
pause
goto MAIN

:MAIN_CMAKE
if not exist %BUILD_DIR% (
    mkdir %BUILD_DIR%
)
cd %BUILD_DIR%
%CMAKE_BIN% -A x64 .. -D CMAKE_INSTALL_PREFIX=%BUILD_BIN% -DUSE_TEST=OFF
goto PAUSE_MENU

:MAIN_BUILD
cd %BUILD_DIR%
%CMAKE_BIN% --build . --config Release
if %errorlevel% == 0 (
    %CMAKE_BIN% --install .
) else (
    echo "Build Error!"
)
goto PAUSE_MENU

:MAIN_CLEAN
if exist %BUILD_DIR% (
    rd /q /s %BUILD_DIR%
)
goto PAUSE_MENU

:PAUSE_MENU
echo.操作完成，按任意键返回主菜单!
pause >nul
goto MAIN
