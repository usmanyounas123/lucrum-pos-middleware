@echo off
echo Starting Lucrum POS Middleware...
cd /d "%~dp0"

REM Check for the correct task name
schtasks /query /tn "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Found Task Scheduler entry, starting...
    schtasks /run /tn "Lucrum-POS-Middleware"
    set TASK_NAME=Lucrum-POS-Middleware
) else (
    REM Try old Windows service as fallback
    echo No scheduled task found, trying Windows service...
    sc query "LucrumPOSMiddleware" >nul 2>&1
    if %errorLevel% equ 0 (
        sc start "LucrumPOSMiddleware"
    ) else (
        echo No scheduled task or service found. Starting directly for testing...
        if exist "lucrum-pos-middleware.exe" (
            start "Lucrum POS Middleware" /min "%~dp0lucrum-pos-middleware.exe"
        ) else (
            echo ERROR: lucrum-pos-middleware.exe not found in this folder
            echo Please run install.bat first
            pause
            exit /b 1
        )
    )
)

echo Waiting for application to start...
timeout /t 5 /nobreak >nul

REM Check if application is running
tasklist /fi "imagename eq lucrum-pos-middleware.exe" 2>nul | find /i "lucrum-pos-middleware.exe" >nul
if %errorLevel% equ 0 (
    echo SUCCESS: Application is RUNNING
    echo API: http://localhost:8081
    echo WebSocket: ws://localhost:8081
) else (
    echo Application may still be starting...
    timeout /t 5 /nobreak >nul
    tasklist /fi "imagename eq lucrum-pos-middleware.exe" 2>nul | find /i "lucrum-pos-middleware.exe" >nul
    if %errorLevel% equ 0 (
    echo SUCCESS: Application is now RUNNING
    echo API: http://localhost:8081
    echo WebSocket: ws://localhost:8081
    ) else (
        echo WARNING: Application not detected
        echo Check Task Scheduler: taskschd.msc
        echo Task name: %TASK_NAME%
    )
)
pause