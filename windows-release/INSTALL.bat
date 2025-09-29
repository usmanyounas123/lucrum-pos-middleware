@echo off
title POS Middleware Windows Installer

echo ==========================================
echo   POS Middleware Windows Installer v2.0.0
echo ==========================================
echo.
echo This installer will:
echo - Install POS Middleware as a Windows Service
echo - Configure auto-start on system boot
echo - Create desktop shortcuts for management
echo - Configure Windows firewall
echo.
echo Requirements:
echo - Windows 10 or later
echo - Node.js 14+ (will be checked)
echo - Administrator privileges
echo.
pause

echo Launching PowerShell installer...
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running as Administrator - Good!
    echo.
    powershell -ExecutionPolicy Bypass -File "windows-installer.ps1"
) else (
    echo This installer must be run as Administrator!
    echo Right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo.
echo Installation process completed.
echo Check the output above for any errors.
echo.
pause