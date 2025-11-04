@ECHO OFF

SET BUILD_DIR=_build
SET CMAKE_BIN="c:\cmake\bin\cmake.exe"
SET CMAKE_CONFIG="Visual Studio 16 2019"

SET PROJ_DIR=%~dp0
SET PROJ_NAME=sample
SET PORJ_CMAKE_OPT= -D CMAKE_BUILD_TYPE=Release ^

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
mkdir %PROJ_DIR%\%BUILD_DIR%
cd %PROJ_DIR%\%BUILD_DIR%
%CMAKE_BIN% -G %CMAKE_CONFIG% .. %PORJ_CMAKE_OPT%
goto PAUSE_MENU

:MAIN_BUILD
cd %PROJ_DIR%\%BUILD_DIR%
%CMAKE_BIN% --build . --config Release
goto PAUSE_MENU

:MAIN_CLEAN
rd /q /s %PROJ_DIR%\%BUILD_DIR%
goto PAUSE_MENU

:PAUSE_MENU
echo.操作完成，按任意键返回主菜单!
pause >nul
goto MAIN
