@echo off
chcp 65001 >nul

set pwd_dir=%~dp0
set http_proxy=192.168.1.5:8888
set https_proxy=192.168.1.5:8888
set cmake_bin=d:\Documents\Android\Sdk\cmake\3.18.1\bin\cmake.exe
set "ndk_dir=d:\Documents\Android\Sdk\ndk\21.0.6113669"

@REM 工程代码
set base_dir=%pwd_dir%\_download
set pack_url=https://curl.se/download/curl-8.16.0.tar.gz
set pack_file=%pwd_dir%\_download\curl-8.16.0.tar.gz
set proj_dir=%pwd_dir%\_download\curl-8.16.0
set build_dir=%pwd_dir%\_download\curl-8.16.0\_build
set build_out=%pwd_dir%\apk\curl
if not exist "%base_dir%" mkdir "%base_dir%"
if not exist "%build_out%" mkdir "%build_out%"
if not exist "%pack_file%" wget "%pack_url%" -O "%pack_file%"
if not exist "%proj_dir%" tar -xvf "%pack_file%" -C "%base_dir%"

@REM CMAKE选项
set OPENSSL_DIR=%pwd_dir%/patch/openssl_arm64
set CMAKE_OPT= ^
    -DCMAKE_TOOLCHAIN_FILE=%ndk_dir%\build\cmake\android.toolchain.cmake ^
    -DCMAKE_MAKE_PROGRAM=ninja ^
    -DANDROID_ABI=arm64-v8a ^
    -DANDROID_PLATFORM=android-21 ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_STATIC_LIBS=ON ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DCURL_STATIC_CRT=ON ^
    -DCURL_USE_SCHANNEL=OFF ^
    -DCURL_USE_OPENSSL=ON ^
    -DOPENSSL_ROOT_DIR=%OPENSSL_DIR% ^
    -DOPENSSL_INCLUDE_DIR=%OPENSSL_DIR%/include ^
    -DOPENSSL_CRYPTO_LIBRARY=%OPENSSL_DIR%/lib/libcrypto.a ^
    -DOPENSSL_SSL_LIBRARY=%OPENSSL_DIR%/lib/libssl.a ^
    -DCURL_USE_LIBPSL=OFF ^
    -DBUILD_CURL_EXE=OFF ^
    -DBUILD_TESTING=OFF ^
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
%cmake_bin% -G "Ninja" %proj_dir% %CMAKE_OPT%
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
