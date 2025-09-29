@echo off
title POS Middleware Uninstaller

echo ==========================================
echo   POS Middleware Uninstaller
echo ==========================================
echo.
echo This will completely remove POS Middleware from your system:
echo - Stop and uninstall the Windows service
echo - Remove all files and directories
echo - Remove desktop shortcuts
echo - Remove firewall rules
echo.
echo Are you sure you want to continue?
pause

echo Launching PowerShell uninstaller...
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running as Administrator - Good!
    echo.
    powershell -ExecutionPolicy Bypass -File "windows-installer.ps1" -Uninstall
) else (
    echo This uninstaller must be run as Administrator!
    echo Right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo.
echo Uninstallation process completed.
echo.
pause