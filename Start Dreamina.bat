@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0DreaminaLauncher.ps1"
set "exit_code=%errorlevel%"
if not "%exit_code%"=="0" (
    echo.
    echo Dreamina Launcher exited with code %exit_code%.
    echo Press any key to close this window.
    pause >nul
)
endlocal & exit /b %exit_code%
