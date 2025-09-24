@echo off
echo ========================================
echo SERVICE DIAGNOSTIC TOOL
echo ========================================

cd /d "%~dp0"

echo Testing service startup in real-time...
echo.

REM First test: Run executable with --service flag
echo [TEST 1] Running with --service flag (10 seconds)
echo Command: pos-middleware.exe --service
echo.
start /b pos-middleware.exe --service
timeout /t 10 /nobreak
taskkill /f /im pos-middleware.exe >nul 2>&1
echo.

REM Second test: Run executable without flags
echo [TEST 2] Running without flags (10 seconds)  
echo Command: pos-middleware.exe
echo.
start /b pos-middleware.exe
timeout /t 10 /nobreak
taskkill /f /im pos-middleware.exe >nul 2>&1
echo.

REM Third test: Check service status if installed
echo [TEST 3] Current service status
sc query "Lucrum-POS-Middleware" 2>nul
if %errorLevel% neq 0 (
    echo Service not installed
) else (
    echo Service is installed
)
echo.

REM Fourth test: Try starting service and immediately check
echo [TEST 4] Service start test
sc query "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    echo Attempting service start...
    sc start "Lucrum-POS-Middleware"
    echo.
    echo Immediate status check:
    sc query "Lucrum-POS-Middleware"
    echo.
    echo Waiting 5 seconds...
    timeout /t 5 /nobreak >nul
    echo Status after 5 seconds:
    sc query "Lucrum-POS-Middleware"
    echo.
    echo Stopping service...
    sc stop "Lucrum-POS-Middleware" >nul 2>&1
) else (
    echo Service not installed - cannot test
)

echo.
echo Diagnostic completed.
echo.
echo ANALYSIS:
echo - If TEST 1 and TEST 2 both show startup messages, the executable works
echo - If TEST 4 shows STOPPED status, there's a service configuration issue
echo - If TEST 4 shows START_PENDING forever, there's a service communication issue
echo.
pause