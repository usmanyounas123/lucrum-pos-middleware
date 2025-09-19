@echo off
echo ================================================
echo     Lucrum POS Middleware - Test Run
echo ================================================
echo.

cd /d "%~dp0"

echo Testing Lucrum POS Middleware executable...
echo Current directory: %~dp0
echo.

echo Checking if executable exists...
if not exist "pos-middleware.exe" (
    echo ERROR: pos-middleware.exe not found in current directory
    pause
    exit /b 1
)

echo Checking configuration file...
if not exist "config.json" (
    echo WARNING: config.json not found, will use defaults
) else (
    echo ✓ config.json found
)

echo.
echo Checking ports 8080 and 8081...
netstat -an | find "8080" >nul 2>&1
if %errorLevel% equ 0 (
    echo WARNING: Port 8080 is already in use
    echo The following process is using port 8080:
    netstat -ano | find "8080"
) else (
    echo ✓ Port 8080 is available
)

netstat -an | find "8081" >nul 2>&1
if %errorLevel% equ 0 (
    echo WARNING: Port 8081 is already in use  
    echo The following process is using port 8081:
    netstat -ano | find "8081"
) else (
    echo ✓ Port 8081 is available
)

echo.
echo Starting application in test mode...
echo Press Ctrl+C to stop the application
echo.
echo API will be available at: http://localhost:8081
echo WebSocket will be available at: ws://localhost:8080
echo.
echo If this works but the service doesn't, there may be a permissions issue.
echo.
echo ================================================

pos-middleware.exe