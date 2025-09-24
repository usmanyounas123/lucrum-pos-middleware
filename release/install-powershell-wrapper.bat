@echo off
cd /d "%~dp0"

echo ========================================
echo LUCRUM POS MIDDLEWARE - ULTRA SIMPLE
echo ========================================
echo.
echo This uses the simplest possible PowerShell + Task Scheduler approach.
echo Direct task creation with NO wrappers or complex scripts.
echo.

REM Check if PowerShell is available
powershell.exe -Command "Get-Host" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell is not available on this system.
    echo Falling back to standard Task Scheduler method...
    echo.
    pause
    call "%~dp0install-task-scheduler.bat"
    exit /b
)

echo Starting ultra-simple installation...
echo.

REM Run the ultra-simple PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "%~dp0install-ultra-simple.ps1"

echo.
echo Ultra-simple installation completed.
pause