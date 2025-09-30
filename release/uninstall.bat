@echo off
echo Uninstalling Lucrum POS Middleware...
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator
    echo Right-click on this file and select "Run as administrator"
    pause
    exit /b 1
)

echo Stopping service...
sc stop "LucrumPOSMiddleware"

echo Deleting service...
sc delete "LucrumPOSMiddleware"

echo.
set /p DELETE_FILES="Delete all files from C:\LucrumPOSMiddleware? (y/n): "
if /i "%DELETE_FILES%"=="y" (
    echo Deleting files...
    rmdir /s /q "C:\LucrumPOSMiddleware"
    echo Files deleted.
) else (
    echo Files preserved at C:\LucrumPOSMiddleware\
)

echo.
echo Uninstallation complete!
pause