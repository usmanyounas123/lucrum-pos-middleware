@echo off
echo Stopping Lucrum POS Middleware...

REM Check if application is running
tasklist /fi "imagename eq lucrum-pos-middleware.exe" 2>nul | find /i "lucrum-pos-middleware.exe" >nul
if %errorLevel% equ 0 (
    echo Stopping application process...
    taskkill /f /im lucrum-pos-middleware.exe >nul 2>&1
    if %errorLevel% equ 0 (
        echo SUCCESS: Application stopped
    ) else (
        echo ERROR: Failed to stop application
    )
) else (
    echo Application is not running
)

REM Also try to stop Windows service if it exists
sc query "LucrumPOSMiddleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Stopping Windows service (if running)...
    sc stop "LucrumPOSMiddleware" >nul 2>&1
    if %errorLevel% equ 0 (
        echo Windows service stopped
    )
)

echo Done.
pause