@echo off
echo ================================================
echo       POS Middleware - Build Executable
echo ================================================
echo.

REM Navigate to the directory containing this script
cd /d "%~dp0.."

echo Installing dependencies...
call npm install
if %errorLevel% neq 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo Building TypeScript...
call npm run build
if %errorLevel% neq 0 (
    echo ERROR: Failed to build TypeScript
    pause
    exit /b 1
)

echo Creating executable...
call npm run build-exe
if %errorLevel% neq 0 (
    echo ERROR: Failed to create executable
    pause
    exit /b 1
)

echo.
echo ================================================
echo       Build Complete!
echo ================================================
echo.
echo Executable created: dist\pos-middleware.exe
echo.
echo You can now distribute this executable to other Windows machines
echo without requiring Node.js installation.
echo.
echo NOTE: Make sure to include:
echo - .env file (configured)
echo - config.json file (configured)  
echo - logs directory
echo.
pause