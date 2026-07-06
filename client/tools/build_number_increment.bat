@echo off
:: Increments versionCode in client\app\build.gradle by 1.
:: versionName is left unchanged (bump it by hand for real version changes).
setlocal

set "GRADLE=%~dp0..\app\build.gradle"
if not exist "%GRADLE%" (
    echo ERROR: app\build.gradle not found at "%GRADLE%".
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "$f='%GRADLE%'; $c=[IO.File]::ReadAllText($f); if($c -notmatch 'versionCode\s+(\d+)'){ Write-Error 'versionCode not found'; exit 1 }; $old=[int]$Matches[1]; $new=$old+1; $c=[regex]::Replace($c,'versionCode\s+\d+',('versionCode '+$new),1); [IO.File]::WriteAllText($f,$c); Write-Host ('versionCode '+$old+' -> '+$new)"
if errorlevel 1 (
    echo ERROR: Failed to increment versionCode.
    exit /b 1
)

endlocal
exit /b 0
