@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Build and Upload Android Release APK
echo ========================================
echo.

set "INI=%~dp0release.ini"
if not exist "%INI%" (
    echo ERROR: "%INI%" not found.
    echo Copy release.ini.example to release.ini and fill in the FTP values.
    pause
    exit /b 1
)

set "CLIENT_DIR=%~dp0.."
set "APK=%CLIENT_DIR%\app\build\outputs\apk\release\app-release.apk"

rem --- Increment versionCode ---
echo [Version] Incrementing versionCode ...
call "%~dp0build_number_increment.bat"
if errorlevel 1 exit /b 1
echo.

rem --- Build ---
echo [Build] Running gradlew assembleRelease ...
pushd "%CLIENT_DIR%"
call gradlew.bat assembleRelease
set "BUILD_RC=%errorlevel%"
popd
if not "%BUILD_RC%"=="0" (
    echo.
    echo ERROR: Build failed ^(exit code %BUILD_RC%^).
    exit /b %BUILD_RC%
)
echo.

if not exist "%APK%" (
    echo ERROR: APK not found at "%APK%"
    exit /b 1
)
for %%I in ("%APK%") do set "APK=%%~fI"

rem --- Parse version from app/build.gradle: versionName "1.5" / versionCode 5 ---
set "VNAME="
set "VCODE="
for /f "tokens=2 delims= " %%a in ('findstr /r /c:"versionName" "%CLIENT_DIR%\app\build.gradle"') do set "VNAME=%%~a"
for /f "tokens=2 delims= " %%a in ('findstr /r /c:"versionCode" "%CLIENT_DIR%\app\build.gradle"') do set "VCODE=%%a"
if "!VNAME!"=="" (
    echo ERROR: Could not parse versionName from app\build.gradle.
    exit /b 1
)
if "!VCODE!"=="" (
    echo ERROR: Could not parse versionCode from app\build.gradle.
    exit /b 1
)
set "TARGET_APK_NAME=app_v!VNAME!_!VCODE!.apk"

rem --- Stage a renamed copy. ftp-sync runs in no-delete mode so older versions stay. ---
set "STAGING=%CLIENT_DIR%\app\build\publish\release"
if not exist "%STAGING%" mkdir "%STAGING%"
copy /y "%APK%" "%STAGING%\!TARGET_APK_NAME!" >nul
if errorlevel 1 (
    echo ERROR: Failed to stage APK to "%STAGING%\!TARGET_APK_NAME!".
    exit /b 1
)

set "APK_LINK_DIR="
for /f "tokens=1,* delims==" %%a in ('findstr /b /i "APK_LINK_DIR=" "%INI%"') do set "APK_LINK_DIR=%%b"

echo [Upload] Syncing release APK via ftp-sync...
call "%~dp0ftpsync_upload.bat" "%INI%" "%STAGING%" "%CLIENT_DIR%\app\build\publish\.ftpsync_release.db"
if errorlevel 1 exit /b 1

echo.
echo ========================================
echo Build and upload completed.
echo Version:     !VNAME! ^(!VCODE!^)
echo Uploaded as: !TARGET_APK_NAME!
echo Link:        !APK_LINK_DIR!/!TARGET_APK_NAME!
echo ========================================
echo.
endlocal
