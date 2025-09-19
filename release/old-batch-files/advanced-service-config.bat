@echo off
echo ================================================
echo Lucrum POS Middleware - Advanced Service Config
echo ================================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator
    echo Please right-click on this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo Applying advanced service configuration fixes...
echo.

REM Stop the service if running
sc stop "Lucrum-POS-Middleware" >nul 2>&1
timeout /t 3 /nobreak >nul

echo 1. Configuring service with extended timeouts...
sc config "Lucrum-POS-Middleware" start= auto
sc config "Lucrum-POS-Middleware" obj= "LocalSystem"
sc config "Lucrum-POS-Middleware" type= own

echo 2. Setting failure recovery options...
sc failure "Lucrum-POS-Middleware" reset= 300 actions= restart/30000/restart/60000/restart/120000

echo 3. Configuring service to interact with desktop (for logging)...
sc config "Lucrum-POS-Middleware" type= interact type= own

echo 4. Setting service description...
sc description "Lucrum-POS-Middleware" "Lucrum POS Middleware Service - Handles communication between POS systems and Lucrum applications"

echo 5. Setting service dependencies...
sc config "Lucrum-POS-Middleware" depend= "RPCSS/EventLog"

echo.
echo 6. Registry modifications for extended timeout...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v ServicesPipeTimeout /t REG_DWORD /d 180000 /f >nul 2>&1

echo.
echo 7. Creating service with PowerShell (alternative method)...
powershell -Command "& {
    $serviceName = 'Lucrum-POS-Middleware-PS'
    $exePath = '%~dp0pos-middleware.exe'
    
    # Remove existing service if it exists
    if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        (Get-WmiObject -Class Win32_Service -Filter \"Name='$serviceName'\").Delete()
    }
    
    # Create new service with PowerShell
    New-Service -Name $serviceName -BinaryPathName $exePath -DisplayName 'Lucrum POS Middleware (PowerShell)' -StartupType Automatic -Description 'Lucrum POS Middleware via PowerShell'
    
    Write-Host 'PowerShell service created: Lucrum-POS-Middleware-PS'
}"

echo.
echo ================================================
echo   Configuration Complete
echo ================================================
echo.
echo Available services:
echo 1. Lucrum-POS-Middleware (original)
echo 2. Lucrum-POS-Middleware-PS (PowerShell created)
echo.
echo Choose which one to start:
echo [1] Original service
echo [2] PowerShell service
echo [3] Skip service start
echo.
choice /c 123 /m "Select option"

if %ERRORLEVEL% equ 1 (
    echo Starting original service...
    sc start "Lucrum-POS-Middleware"
    if %errorLevel% equ 0 (
        echo ✓ Original service started successfully!
    ) else (
        echo ✗ Original service failed to start
    )
)

if %ERRORLEVEL% equ 2 (
    echo Starting PowerShell service...
    sc start "Lucrum-POS-Middleware-PS"
    if %errorLevel% equ 0 (
        echo ✓ PowerShell service started successfully!
    ) else (
        echo ✗ PowerShell service failed to start
    )
)

if %ERRORLEVEL% equ 3 (
    echo Skipping service start. You can manually start either:
    echo - sc start "Lucrum-POS-Middleware"
    echo - sc start "Lucrum-POS-Middleware-PS"
)

echo.
echo If services still fail, try the scheduled task approach:
echo Run install-task.bat instead
echo.
pause