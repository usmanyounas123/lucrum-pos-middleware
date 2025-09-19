@echo off
echo ================================================
echo    Lucrum POS Middleware - Quick Status
echo ================================================
echo.

echo Checking if Lucrum-POS-Middleware service exists...
sc query "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ SERVICE IS INSTALLED
    echo.
    echo Service Details:
    sc query "Lucrum-POS-Middleware"
    echo.
    echo Service Configuration:
    sc qc "Lucrum-POS-Middleware" | findstr "DISPLAY_NAME BINARY_PATH_NAME START_TYPE"
    echo.
    
    REM Check if the executable path exists
    echo Checking executable path...
    for /f "tokens=2*" %%a in ('sc qc "Lucrum-POS-Middleware" ^| findstr BINARY_PATH_NAME') do (
        set "SERVICE_PATH=%%b"
    )
    setlocal enabledelayedexpansion
    set "SERVICE_PATH=!SERVICE_PATH:"=!"
    if exist "!SERVICE_PATH!" (
        echo ✓ Service executable found at: !SERVICE_PATH!
    ) else (
        echo ✗ Service executable NOT FOUND at: !SERVICE_PATH!
        echo   This is likely causing startup failures
        echo   Run fix-service-path.bat to fix this issue
    )
    echo.
    echo RECOMMENDATION: Your service is installed.
    echo - To start it: run start-service.bat
    echo - To check if it's working: open http://localhost:8081 in browser
    echo - To update it: run update-service.bat as Administrator
) else (
    echo ✗ SERVICE IS NOT INSTALLED
    echo.
    echo RECOMMENDATION: Run install.bat as Administrator to install the service
)

echo.
echo Checking ports:
netstat -an | find "8081" >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Port 8081 is in use (API may be running)
) else (
    echo ✗ Port 8081 is not in use (API not running)
)

netstat -an | find "8080" >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Port 8080 is in use (WebSocket may be running)
) else (
    echo ✗ Port 8080 is not in use (WebSocket not running)
)

echo.
pause