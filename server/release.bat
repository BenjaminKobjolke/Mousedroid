@echo off
setlocal
cd /d "%~dp0"

rem --- locate Visual Studio (C++ tools) ---
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" ( echo ERROR: Visual Studio 2022 not found. & pause & exit /b 1 )
for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSINSTALL=%%i"
if not defined VSINSTALL ( echo ERROR: VS C++ tools not installed. & pause & exit /b 1 )

rem --- locate vcpkg (install.bat sets this up); private var survives VsDevCmd ---
if defined VCPKG_ROOT ( set "VCPKG_DIR=%VCPKG_ROOT%" ) else ( set "VCPKG_DIR=%USERPROFILE%\vcpkg" )
if not exist "%VCPKG_DIR%\scripts\buildsystems\vcpkg.cmake" ( echo ERROR: vcpkg not found at "%VCPKG_DIR%". Run install.bat first. & pause & exit /b 1 )

rem --- dev environment: adds cl, cmake, ninja to PATH (note: overwrites VCPKG_ROOT) ---
call "%VSINSTALL%\Common7\Tools\VsDevCmd.bat" -arch=amd64 -host_arch=amd64

rem --- wipe stale cache: toolchain file is locked once a CMakeCache exists ---
if exist "out\build\x64-Release\CMakeCache.txt" rmdir /s /q "out\build\x64-Release"

rem --- configure + build (matches CMakeSettings.json x64-Release) ---
cmake -G Ninja -B "out\build\x64-Release" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_TOOLCHAIN_FILE="%VCPKG_DIR%\scripts\buildsystems\vcpkg.cmake" -DVCPKG_TARGET_TRIPLET=x64-windows || ( echo CMake configure failed & pause & exit /b 1 )
cmake --build "out\build\x64-Release" || ( echo Build failed & pause & exit /b 1 )

rem --- existing deploy ---
xcopy "out\build\x64-Release\bin\*.*" "dist\" /E /I /Y /H

xcopy "adb" "dist\adb\" /E /I /Y

copy /y app.ico dist

(
    echo MINIMIZE_TASKBAR=0
    echo MOVE_SENSITIVITY=10
    echo RUN_STARTUP=0
    echo SCROLL_SENSITIVITY=3
)>distconfig.ini

echo Deployment to "dist" complete!
pause
