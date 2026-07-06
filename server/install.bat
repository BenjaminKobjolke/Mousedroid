@echo off
setlocal
cd /d "%~dp0"

if not defined VCPKG_ROOT set "VCPKG_ROOT=%USERPROFILE%\vcpkg"

where git >nul 2>&1 || ( echo ERROR: git required on PATH. & pause & exit /b 1 )

if not exist "%VCPKG_ROOT%\vcpkg.exe" (
    echo Cloning vcpkg to "%VCPKG_ROOT%"...
    git clone https://github.com/microsoft/vcpkg "%VCPKG_ROOT%" || ( echo clone failed & pause & exit /b 1 )
    call "%VCPKG_ROOT%\bootstrap-vcpkg.bat" || ( echo bootstrap failed & pause & exit /b 1 )
)

echo Installing dependencies (wxWidgets compile can take 30+ min first run)...
"%VCPKG_ROOT%\vcpkg.exe" install asio:x64-windows wxwidgets:x64-windows || ( echo dependency install failed & pause & exit /b 1 )

echo.
echo Setup complete. vcpkg at "%VCPKG_ROOT%". Now run release.bat.
pause
