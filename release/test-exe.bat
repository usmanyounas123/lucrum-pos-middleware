@echo off
echo ===================================================
echo LUCRUM POS MIDDLEWARE - EXECUTABLE TEST
echo ===================================================

cd /d "%~dp0"

if not exist "pos-middleware.exe" (
    echo ERROR: pos-middleware.exe not found
    pause
    exit /b 1
)

echo Testing pos-middleware.exe directly...
echo This will run the application for 15 seconds to verify it works.
echo.
echo Starting application...
echo (Press Ctrl+C if you want to stop early)
echo.

REM Run the executable directly for testing
start /b pos-middleware.exe --test

echo Waiting 15 seconds...
timeout /t 15 /nobreak

echo.
echo Stopping test application...
taskkill /f /im pos-middleware.exe >nul 2>&1

echo.
echo Test completed. If you saw startup messages above, the executable works correctly.
echo The service timeout issue is likely related to Windows service management.
echo.
echo Try running: install-improved.bat for better service installation.
echo.
pause