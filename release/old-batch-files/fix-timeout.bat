@echo off
echo ================================================
echo  Lucrum POS Middleware - Fix Service Timeout
echo ================================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator
    echo Please right-click on this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo Diagnosing and fixing Lucrum POS Middleware timeout issue...
echo.

REM Navigate to the directory containing this script
cd /d "%~dp0"

echo 1. Stopping service if running...
sc stop "Lucrum-POS-Middleware" >nul 2>&1
timeout /t 3 /nobreak >nul

echo 2. Checking for port conflicts...
netstat -ano | findstr ":8080" >nul 2>&1
if %errorLevel% equ 0 (
    echo WARNING: Port 8080 is in use by another process
    echo Processes using port 8080:
    netstat -ano | findstr ":8080"
    echo.
    echo You may need to stop these processes or change the port in config.json
    echo.
)

netstat -ano | findstr ":8081" >nul 2>&1
if %errorLevel% equ 0 (
    echo WARNING: Port 8081 is in use by another process
    echo Processes using port 8081:
    netstat -ano | findstr ":8081"
    echo.
    echo You may need to stop these processes or change the port in config.json
    echo.
)

echo 3. Checking executable permissions...
icacls pos-middleware.exe | findstr "NT AUTHORITY\\SYSTEM" >nul 2>&1
if %errorLevel% neq 0 (
    echo Fixing permissions for LocalSystem account...
    icacls pos-middleware.exe /grant "NT AUTHORITY\SYSTEM:F" /T
    icacls config.json /grant "NT AUTHORITY\SYSTEM:F" /T 2>nul
    icacls .env /grant "NT AUTHORITY\SYSTEM:F" /T 2>nul
    icacls logs /grant "NT AUTHORITY\SYSTEM:F" /T 2>nul
    echo Permissions updated.
) else (
    echo ✓ Permissions look correct
)

echo.
echo 4. Updating service configuration for better timeout handling...
sc config "Lucrum-POS-Middleware" start= auto
sc failure "Lucrum-POS-Middleware" reset= 60 actions= restart/30000/restart/30000/restart/30000

echo.
echo 5. Testing executable directly first...
echo This will help identify if the issue is with the executable or service configuration.
echo.
echo Starting pos-middleware.exe in test mode...
echo If this fails, the issue is with the executable.
echo If this works, the issue is with the service configuration.
echo.
echo Press Ctrl+C to stop the test after a few seconds if it starts successfully.
echo.

REM Test run with timeout
timeout /t 2 /nobreak >nul
start /wait /b cmd /c "pos-middleware.exe & timeout /t 10 /nobreak >nul & taskkill /f /im pos-middleware.exe >nul 2>&1"

echo.
echo 6. Attempting to start service with extended timeout...
echo.
sc start "Lucrum-POS-Middleware"

if %errorLevel% equ 0 (
    echo.
    echo ================================================
    echo           SUCCESS!
    echo ================================================
    echo.
    echo Lucrum POS Middleware service started successfully!
    echo API should be available at: http://localhost:8081
    echo WebSocket should be available at: ws://localhost:8080
) else (
    echo.
    echo ================================================
    echo        Still Having Issues?
    echo ================================================
    echo.
    echo Try these steps:
    echo 1. Run test-run.bat to test the executable directly
    echo 2. Check Windows Event Viewer for detailed error messages
    echo 3. Ensure no antivirus is blocking the executable
    echo 4. Try running the service with a different user account:
    echo    sc config "Lucrum-POS-Middleware" obj= "LocalService"
    echo.
    echo If the executable runs fine with test-run.bat but fails as a service,
    echo this is likely a Windows service permissions or configuration issue.
)

echo.
pause