@echo off
REM Windows Service Batch Wrapper for Lucrum POS Middleware
REM This script runs as a Windows service and manages the Node.js application

cd /d "%~dp0"
setlocal EnableDelayedExpansion

set LOG_FILE=%~dp0logs\batch-wrapper.log
set APP_EXE=%~dp0pos-middleware.exe
set PID_FILE=%~dp0service.pid

REM Ensure logs directory exists
if not exist "%~dp0logs" mkdir "%~dp0logs"

REM Function to log messages
call :log "=== Batch Service Wrapper Starting ==="
call :log "Wrapper PID: %pid%"
call :log "Working Directory: %CD%"
call :log "Application: %APP_EXE%"

REM Check if application exists
if not exist "%APP_EXE%" (
    call :log "ERROR: Application executable not found: %APP_EXE%"
    exit /b 1
)

REM Start the main application
call :log "Starting main application..."
start /min "Lucrum POS Service" "%APP_EXE%"

REM Monitor the application
:monitor
timeout /t 5 /nobreak >nul

REM Check if application is still running
tasklist /FI "IMAGENAME eq pos-middleware.exe" 2>nul | find /I "pos-middleware.exe" >nul
if %ERRORLEVEL% NEQ 0 (
    call :log "Application stopped, restarting..."
    start /min "Lucrum POS Service" "%APP_EXE%"
    timeout /t 10 /nobreak >nul
)

REM Continue monitoring
goto :monitor

REM Logging function
:log
echo [%date% %time%] %~1 >> "%LOG_FILE%"
echo [%date% %time%] %~1
goto :eof