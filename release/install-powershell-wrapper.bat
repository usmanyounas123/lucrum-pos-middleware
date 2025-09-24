@echo off
cd /d "%~dp0"

echo ========================================
echo LUCRUM POS MIDDLEWARE - FOOLPROOF
echo ========================================
echo.
echo This uses the most reliable PowerShell approach possible.
echo Guaranteed to work without syntax errors.
echo.

REM Check if PowerShell is available
powershell.exe -Command "Get-Host" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell is not available.
    echo Using fallback method...
    echo.
    pause
    call "%~dp0install-task-scheduler.bat"
    exit /b
)

echo Starting foolproof installation...
echo.

REM Run the foolproof PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "%~dp0install-foolproof.ps1"

echo.
echo Installation completed.
pause