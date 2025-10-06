@echo off
echo ========================================
echo LUCRUM POS MIDDLEWARE - UNINSTALLER
echo ========================================

REM Check admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Run as Administrator
    echo Right-click on this file and select "Run as administrator"
    pause
    exit /b 1
)

echo Stopping application...
taskkill /f /im lucrum-pos-middleware.exe >nul 2>&1

echo.
echo Removing scheduled tasks...
REM Remove scheduled task (current)
schtasks /delete /tn "Lucrum-POS-Middleware" /f >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Removed scheduled task
)

echo.
echo Removing Windows service (if exists)...
sc query "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    sc stop "Lucrum-POS-Middleware" >nul 2>&1
    timeout /t 3 /nobreak >nul
    sc delete "Lucrum-POS-Middleware" >nul 2>&1
    echo ✓ Removed Windows service
) else (
    echo No Windows service found (normal if using Task Scheduler)
)

echo.
echo Cleaning up old installation directory...
if exist "C:\LucrumPOSMiddleware" (
    set /p DELETE_FILES="Delete all files from C:\LucrumPOSMiddleware? (y/n): "
    if /i "!DELETE_FILES!"=="y" (
        rmdir /s /q "C:\LucrumPOSMiddleware" >nul 2>&1
        echo ✓ Removed C:\LucrumPOSMiddleware directory
    ) else (
        echo Files preserved at C:\LucrumPOSMiddleware\
    )
)

echo.
echo Uninstallation complete!
echo.
echo NOTE: Application files remain in this directory
echo You can manually delete this folder if no longer needed
echo.
pause