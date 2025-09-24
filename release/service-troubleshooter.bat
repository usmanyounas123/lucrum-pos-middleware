@echo off
echo ===================================================
echo LUCRUM POS MIDDLEWARE - ADVANCED TROUBLESHOOTER
echo ===================================================

cd /d "%~dp0"

echo Step 1: Environment Check...
echo Current directory: %CD%
echo Current user: %USERNAME%
echo Windows version: 
ver

echo.
echo Step 2: File verification...
if exist "pos-middleware.exe" (
    echo ✓ pos-middleware.exe found
    for %%A in (pos-middleware.exe) do echo   Size: %%~zA bytes
) else (
    echo ✗ ERROR: pos-middleware.exe not found
    goto :end
)

if exist ".env" (
    echo ✓ .env file found
) else (
    echo ⚠ WARNING: .env file not found
)

if exist "config.json" (
    echo ✓ config.json found
) else (
    echo ⚠ WARNING: config.json not found
)

echo.
echo Step 3: Service status check...
sc query "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ Service exists
    sc query "Lucrum-POS-Middleware"
    echo.
    
    REM Get service configuration
    echo Service configuration:
    sc qc "Lucrum-POS-Middleware"
    echo.
) else (
    echo ✗ ERROR: Service not installed
    echo Run install-improved.bat first
    goto :end
)

echo Step 4: Port availability check...
netstat -an | find "8081" >nul 2>&1
if %errorLevel% equ 0 (
    echo ⚠ WARNING: Port 8081 is in use
    echo Processes using port 8081:
    netstat -ano | findstr ":8081"
) else (
    echo ✓ Port 8081 available
)

netstat -an | find "8080" >nul 2>&1
if %errorLevel% equ 0 (
    echo ⚠ WARNING: Port 8080 is in use
    echo Processes using port 8080:
    netstat -ano | findstr ":8080"
) else (
    echo ✓ Port 8080 available
)

echo.
echo Step 5: Testing executable directly...
echo Running pos-middleware.exe for 10 seconds to test...
start /b pos-middleware.exe --test
timeout /t 10 /nobreak >nul
taskkill /f /im pos-middleware.exe >nul 2>&1

echo.
echo Step 6: Service start attempt with monitoring...
echo Stopping service if running...
sc stop "Lucrum-POS-Middleware" >nul 2>&1
timeout /t 5 /nobreak >nul

echo Starting service with extended monitoring...
sc start "Lucrum-POS-Middleware"
echo Start command issued, monitoring for 90 seconds...

set /a counter=0
:loop
timeout /t 3 /nobreak >nul
set /a counter+=3

sc query "Lucrum-POS-Middleware" | findstr "RUNNING" >nul 2>&1
if %errorLevel% equ 0 (
    echo.
    echo ========================================
    echo ✓ SUCCESS: Service is now RUNNING
    echo ========================================
    echo Started successfully after %counter% seconds
    echo API: http://localhost:8081
    echo WebSocket: ws://localhost:8080
    goto :end
)

sc query "Lucrum-POS-Middleware" | findstr "START_PENDING" >nul 2>&1
if %errorLevel% equ 0 (
    echo [%counter%s] Service is starting (START_PENDING)...
) else (
    sc query "Lucrum-POS-Middleware" | findstr "STOPPED" >nul 2>&1
    if %errorLevel% equ 0 (
        echo [%counter%s] Service stopped unexpectedly
        goto :failed
    ) else (
        echo [%counter%s] Service status unknown, checking...
    )
)

if %counter% lss 90 goto :loop

:failed
echo.
echo ========================================
echo ✗ SERVICE START FAILED
echo ========================================
echo Final service status:
sc query "Lucrum-POS-Middleware"

echo.
echo DETAILED TROUBLESHOOTING:
echo.
echo 1. Check Windows Event Viewer:
echo    - Windows Logs ^> System
echo    - Windows Logs ^> Application
echo    - Look for "Lucrum-POS-Middleware" entries
echo.
echo 2. Try manual executable test:
echo    pos-middleware.exe
echo    (Press Ctrl+C to stop)
echo.
echo 3. Check file permissions:
echo    - Ensure SYSTEM account has full access
echo    - Try running as different user
echo.
echo 4. Antivirus check:
echo    - Temporarily disable antivirus
echo    - Add exclusion for this folder
echo.
echo 5. Dependencies:
echo    - Ensure Visual C++ Redistributable is installed
echo    - Check Windows updates
echo.
echo 6. Alternative installation:
echo    - Try install-improved.bat as Administrator
echo    - Consider different installation directory
echo.

:end
echo.
echo Troubleshooting completed.
pause