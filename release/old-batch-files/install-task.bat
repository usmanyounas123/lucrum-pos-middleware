@echo off
echo ================================================
echo    Lucrum POS Middleware - Install as Task
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

echo Since the Windows service is having timeout issues, let's set up
echo the Lucrum POS Middleware to run as a scheduled task instead.
echo This is often more reliable than Windows services.
echo.

REM Navigate to the directory containing this script
cd /d "%~dp0"

echo Creating scheduled task...

REM Delete existing task if it exists
schtasks /delete /tn "Lucrum-POS-Middleware" /f >nul 2>&1

REM Create new scheduled task
schtasks /create /tn "Lucrum-POS-Middleware" /tr "\"%~dp0pos-middleware.exe\"" /sc onstart /ru SYSTEM /rl HIGHEST /f

if %errorLevel% neq 0 (
    echo ERROR: Failed to create scheduled task
    pause
    exit /b 1
)

echo.
echo Starting the scheduled task...
schtasks /run /tn "Lucrum-POS-Middleware"

if %errorLevel% neq 0 (
    echo ERROR: Failed to start scheduled task
    pause
    exit /b 1
)

echo.
echo ================================================
echo    Scheduled Task Created Successfully!
echo ================================================
echo.
echo Task Name: Lucrum-POS-Middleware
echo Executable: %~dp0pos-middleware.exe
echo Run Level: System (Highest privileges)
echo Trigger: At system startup
echo.
echo The application should now be running!
echo.
echo Management commands:
echo - To stop: schtasks /end /tn "Lucrum-POS-Middleware"
echo - To start: schtasks /run /tn "Lucrum-POS-Middleware"
echo - To delete: schtasks /delete /tn "Lucrum-POS-Middleware" /f
echo.
echo You can also manage it through Task Scheduler (taskschd.msc)
echo.
echo Testing in 5 seconds...
timeout /t 5 /nobreak >nul

echo.
echo Testing API endpoint...
curl -s http://localhost:8081/api/v1/health >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ API is responding on port 8081
    echo ✓ Lucrum POS Middleware is running successfully!
) else (
    echo ✗ API not responding yet, please wait a moment and try again
    echo You can test manually by opening: http://localhost:8081/api/v1/health
)

echo.
pause