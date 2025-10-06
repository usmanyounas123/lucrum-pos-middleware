@echo off
echo ================================================
echo    Lucrum POS Middleware - Direct Test Run
================================================
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
    dir *.exe
    echo.
    pause
    exit /b 1
)

echo Creating logs directory if needed...
if not exist "logs" mkdir logs

echo Starting Lucrum POS Middleware directly...
echo.
echo Expected URLs:
echo - API: http://localhost:8081/api/health
echo - WebSocket: ws://localhost:8081
echo.
echo If you see any errors, they will appear below:
echo ================================================
echo.

REM Run the executable directly so we can see all output
lucrum-pos-middleware.exe

echo.
echo ================================================
echo Middleware stopped. Check above for any errors.
pause