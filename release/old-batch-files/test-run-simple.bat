@echo off
echo ================================================
echo      Lucrum POS Middleware - Quick Test
echo ================================================
echo.

echo This will start the middleware temporarily for testing
echo Press Ctrl+C to stop when done testing
echo.

cd /d "%~dp0"

if not exist "pos-middleware.exe" (
    echo ERROR: pos-middleware.exe not found
    pause
    exit /b 1
)

echo Creating logs directory if needed...
if not exist "logs" mkdir logs

echo Starting Lucrum POS Middleware...
echo.
echo ✓ API will be available at: http://localhost:8081
echo ✓ WebSocket will be available at: ws://localhost:8080
echo ✓ API Key for testing: test-api-key-123
echo.
echo Press Ctrl+C to stop the test
echo.

pos-middleware.exe