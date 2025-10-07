@echo off
echo ================================================
echo    Lucrum POS Middleware - Direct Test
echo ================================================
echo.
echo This will run the middleware directly in this window
echo so you can see any error messages immediately.
echo.
echo Press Ctrl+C to stop when done testing
echo.

cd /d "%~dp0"

if not exist "lucrum-pos-middleware.exe" (
    echo ERROR: lucrum-pos-middleware.exe not found in current directory
    echo Current path: %CD%
    echo.
    echo Available files:
    dir *.exe 2>nul
    if %errorLevel% neq 0 (
        echo No .exe files found
    )
    echo.
    echo Please run install.bat first
    pause
    exit /b 1
)

echo Creating logs directory if needed...
if not exist "logs" mkdir logs

echo.
echo Expected URLs after startup:
echo - API: http://localhost:8081/api/health
echo - WebSocket: ws://localhost:8081
echo - Test Page: Open test.html in browser
echo.
echo Starting Lucrum POS Middleware directly...
echo ================================================
echo.

REM Stop any existing instances first
taskkill /f /im lucrum-pos-middleware.exe >nul 2>&1

REM Run the executable directly so we can see all output
lucrum-pos-middleware.exe

echo.
echo ================================================
echo Middleware stopped. 
echo.
echo If you saw errors above:
echo 1. Check if port 8081 is already in use
echo 2. Verify config.json settings
echo 3. Check antivirus software isn't blocking
echo 4. Try running install.bat as Administrator
echo.
pause