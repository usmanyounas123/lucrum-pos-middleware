@echo off
echo ========================================
echo NODE.JS SERVICE INSTALLER
echo ========================================

REM Check if Node.js is available
node --version >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    echo.
    echo Alternative: Use install-ultimate.bat instead
    pause
    exit /b 1
)

REM Check admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Run as Administrator
    pause
    exit /b 1
)

cd /d "%~dp0"

echo Using Node.js service installer...
echo This method may work better than direct SC commands.
echo.

node node-service-installer.js

pause