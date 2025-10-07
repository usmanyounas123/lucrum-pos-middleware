@echo off
echo ================================================
echo     Stopping Lucrum POS Middleware
echo ================================================
echo.

REM Method 1: Stop Task Scheduler entry
echo Checking for Task Scheduler entry...
schtasks /query /tn "LucrumPOSMiddleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Stopping scheduled task...
    schtasks /end /tn "LucrumPOSMiddleware" >nul 2>&1
    if %errorLevel% equ 0 (
        echo ✓ Scheduled task stopped
    )
) else (
    echo No scheduled task found
)

REM Method 2: Stop Windows Service
echo Checking for Windows Service...
sc query "LucrumPOSMiddleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Stopping Windows service...
    sc stop "LucrumPOSMiddleware"
    if %errorLevel% equ 0 (
        echo ✓ Service stopped successfully
    ) else (
        echo ✗ Service stop failed or was already stopped
    )
) else (
    echo No Windows service found
)

REM Method 3: Stop legacy Scheduled Task
echo Checking for legacy Scheduled Task...
schtasks /query /tn "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Stopping legacy scheduled task...
    schtasks /end /tn "Lucrum-POS-Middleware" >nul 2>&1
    if %errorLevel% equ 0 (
        echo ✓ Legacy scheduled task stopped
    )
) else (
    echo No legacy scheduled task found
)

REM Method 4: Force kill any direct processes
echo Checking for direct processes...
tasklist /fi "imagename eq lucrum-pos-middleware.exe" 2>nul | find /i "lucrum-pos-middleware.exe" >nul
if %errorLevel% equ 0 (
    echo Stopping direct processes...
    taskkill /f /im lucrum-pos-middleware.exe >nul 2>&1
    if %errorLevel% equ 0 (
        echo ✓ Direct processes stopped
    )
) else (
    echo No direct processes found
)

echo.
echo Verifying shutdown...
timeout /t 3 /nobreak >nul

tasklist /fi "imagename eq lucrum-pos-middleware.exe" 2>nul | find /i "lucrum-pos-middleware.exe" >nul
if %errorLevel% equ 0 (
    echo ✗ WARNING: Some processes may still be running
    echo Try running this script again or restart Windows
) else (
    echo ✓ SUCCESS: All middleware processes stopped
)

echo.
echo Middleware shutdown complete.
pause