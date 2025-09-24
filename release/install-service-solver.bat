@echo off
echo ========================================
echo LUCRUM POS MIDDLEWARE - SERVICE SOLVER
echo ========================================

REM Check admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Run as Administrator
    pause
    exit /b 1
)

cd /d "%~dp0"

echo Based on your diagnostic results, we have a specialized solution.
echo.
echo The diagnostic showed:
echo ✓ Executable works perfectly in both modes
echo ✗ Windows Service Control Manager communication issue
echo.
echo SOLUTION: Using service-optimized executable with enhanced SCM communication
echo.

REM Check if service-optimized executable exists
if exist "pos-middleware-service.exe" (
    set EXECUTABLE=pos-middleware-service.exe
    echo Using service-optimized executable: pos-middleware-service.exe
) else (
    set EXECUTABLE=pos-middleware.exe
    echo Using standard executable: pos-middleware.exe
)

echo.
echo [STEP 1] Testing service-optimized executable...
start /b %EXECUTABLE% --service
timeout /t 8 /nobreak

tasklist /fi "imagename eq %EXECUTABLE%" 2>nul | find /i "%EXECUTABLE%" >nul
if %errorLevel% equ 0 (
    echo ✓ Service-optimized executable works correctly
    taskkill /f /im %EXECUTABLE% >nul 2>&1
) else (
    echo ✗ Service-optimized executable failed
    echo Falling back to standard executable
    set EXECUTABLE=pos-middleware.exe
)

REM Clean up existing service
echo.
echo [STEP 2] Removing existing service...
sc query "Lucrum-POS-Middleware" >nul 2>&1
if %errorLevel% equ 0 (
    sc stop "Lucrum-POS-Middleware" >nul 2>&1
    timeout /t 10 /nobreak >nul
    sc delete "Lucrum-POS-Middleware" >nul 2>&1
    timeout /t 5 /nobreak >nul
    echo Existing service removed
)

REM Setup environment
echo.
echo [STEP 3] Environment setup...
if not exist "logs" mkdir logs
if not exist "data.db" echo. > data.db

REM Set permissions
icacls "%~dp0" /grant "SYSTEM:(OI)(CI)F" /T >nul 2>&1
icacls "%~dp0%EXECUTABLE%" /grant "SYSTEM:F" >nul 2>&1

REM Create service with service-optimized settings
echo.
echo [STEP 4] Installing service with %EXECUTABLE%...
sc create "Lucrum-POS-Middleware" ^
   binPath= "\"%~dp0%EXECUTABLE%\" --service" ^
   start= auto ^
   type= own ^
   DisplayName= "Lucrum POS Middleware" ^
   obj= "LocalSystem" ^
   depend= ""

if %errorLevel% neq 0 (
    echo ERROR: Service creation failed
    pause
    exit /b 1
)

REM Configure service
sc config "Lucrum-POS-Middleware" start= auto
sc failure "Lucrum-POS-Middleware" reset= 60 actions= restart/30000/restart/60000/restart/120000
sc description "Lucrum-POS-Middleware" "Lucrum POS Middleware - Enhanced Service Communication"

echo Service installed successfully.

REM Start with real-time monitoring
echo.
echo [STEP 5] Starting service with real-time monitoring...
echo Starting service...
sc start "Lucrum-POS-Middleware"

echo.
echo Real-time monitoring (60 seconds maximum)...
set /a timer=0

:real_time_monitor
timeout /t 2 /nobreak >nul
set /a timer+=2

REM Get current state
for /f "tokens=4" %%i in ('sc query "Lucrum-POS-Middleware" ^| find "STATE"') do set state=%%i

if "%state%"=="RUNNING" (
    echo.
    echo ========================================
    echo ✅ SUCCESS! SERVICE IS RUNNING
    echo ========================================
    echo Service started in %timer% seconds using %EXECUTABLE%
    echo.
    echo 🌐 API: http://localhost:8081
    echo 🔌 WebSocket: ws://localhost:8080
    echo 📝 Logs: %CD%\logs\app.log
    echo.
    echo The service is running in the background.
    goto :success_end
)

if "%state%"=="START_PENDING" (
    echo [%timer%s] Service starting... (%state%)
    if %timer% lss 60 goto :real_time_monitor
    goto :timeout_error
)

if "%state%"=="STOPPED" (
    echo [%timer%s] Service stopped unexpectedly
    goto :error_analysis
)

echo [%timer%s] Current state: %state%
if %timer% lss 60 goto :real_time_monitor

:timeout_error
echo.
echo ========================================
echo TIMEOUT - SERVICE STILL STARTING
echo ========================================
echo Service is taking longer than 60 seconds to start.
echo This is unusual but may still succeed.
goto :error_analysis

:error_analysis
echo.
echo ========================================
echo SERVICE ANALYSIS
echo ========================================
echo Final service status:
sc query "Lucrum-POS-Middleware"
echo.
echo POSSIBLE CAUSES:
echo 1. Port conflict (8081 or 8080 in use)
echo 2. Antivirus blocking executable
echo 3. Insufficient permissions
echo 4. Missing dependencies
echo.
echo NEXT STEPS:
echo 1. Check Windows Event Viewer
echo 2. Run: netstat -ano ^| findstr "8081"
echo 3. Temporarily disable antivirus
echo 4. Try: %EXECUTABLE% --service (direct test)
echo.

:success_end
echo.
echo MANAGEMENT:
echo - Start:  manage.bat start
echo - Stop:   manage.bat stop  
echo - Status: status.bat
echo.
pause