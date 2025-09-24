# PowerShell Task Scheduler Installation for Lucrum POS Middleware
param(
    [string]$InstallPath = $PSScriptRoot
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "LUCRUM POS MIDDLEWARE - POWERSHELL TASK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This method uses PowerShell + Task Scheduler for bulletproof reliability." -ForegroundColor Yellow
Write-Host "Completely bypasses ALL Windows Service issues." -ForegroundColor Yellow
Write-Host ""

$TaskName = "Lucrum-POS-Middleware-PowerShell"
$AppExe = Join-Path $InstallPath "pos-middleware.exe"
$LogFile = Join-Path $InstallPath "logs\powershell-task.log"

# Ensure logs directory exists
$LogDir = Split-Path $LogFile -Parent
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] $Message"
    Write-Host $LogEntry
    Add-Content -Path $LogFile -Value $LogEntry
}

Write-Log "=== PowerShell Task Scheduler Installation Started ==="

# Step 1: Verify application
Write-Host "[STEP 1] Verifying application..." -ForegroundColor Green

if (!(Test-Path $AppExe)) {
    Write-Host "ERROR: pos-middleware.exe not found at $AppExe" -ForegroundColor Red
    Write-Log "ERROR: Application executable not found"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Log "Testing application startup..."
$TestProcess = Start-Process -FilePath $AppExe -WindowStyle Hidden -PassThru

Start-Sleep -Seconds 5

if ($TestProcess.HasExited) {
    Write-Host "ERROR: Application exited immediately" -ForegroundColor Red
    Write-Log "ERROR: Application failed to start properly"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✓ Application starts successfully" -ForegroundColor Green
Write-Log "Application test successful"

# Stop test process
Stop-Process -Id $TestProcess.Id -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Step 2: Clean up existing installations
Write-Host ""
Write-Host "[STEP 2] Cleaning up existing installations..." -ForegroundColor Green

# Stop any running processes
Get-Process -Name "pos-middleware" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Remove existing Windows service
try {
    $Service = Get-Service -Name "Lucrum-POS-Middleware" -ErrorAction SilentlyContinue
    if ($Service) {
        Stop-Service -Name "Lucrum-POS-Middleware" -Force -ErrorAction SilentlyContinue
        & sc.exe delete "Lucrum-POS-Middleware" | Out-Null
    }
} catch {}

# Remove existing scheduled task
try {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
    Write-Log "Existing task removed"
} catch {}

# Step 3: Create PowerShell wrapper script
Write-Host ""
Write-Host "[STEP 3] Creating PowerShell wrapper script..." -ForegroundColor Green

$WrapperScript = @'
# PowerShell Service Wrapper for Lucrum POS Middleware
param(
    [string]$LogPath,
    [string]$AppPath
)

$ErrorActionPreference = "Continue"

function Write-ServiceLog {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] WRAPPER: $Message"
    try {
        Add-Content -Path $LogPath -Value $LogEntry -ErrorAction SilentlyContinue
    } catch {}
}

Write-ServiceLog "=== PowerShell Wrapper Started ==="
Write-ServiceLog "PID: $PID"
Write-ServiceLog "Application: $AppPath"

# Start the main application
Write-ServiceLog "Starting main application..."
try {
    $Process = Start-Process -FilePath $AppPath -WindowStyle Hidden -PassThru -ErrorAction Stop
    Write-ServiceLog "Application started with PID: $($Process.Id)"
    
    # Monitor the application
    while ($true) {
        Start-Sleep -Seconds 30
        
        if ($Process.HasExited) {
            Write-ServiceLog "Application exited with code: $($Process.ExitCode)"
            Write-ServiceLog "Restarting application..."
            
            try {
                $Process = Start-Process -FilePath $AppPath -WindowStyle Hidden -PassThru -ErrorAction Stop
                Write-ServiceLog "Application restarted with PID: $($Process.Id)"
            } catch {
                Write-ServiceLog "Failed to restart application: $($_.Exception.Message)"
                Start-Sleep -Seconds 60
            }
        } else {
            Write-ServiceLog "Health check: Application running (PID: $($Process.Id))"
        }
    }
} catch {
    Write-ServiceLog "Failed to start application: $($_.Exception.Message)"
    exit 1
}
'@

$WrapperPath = Join-Path $InstallPath "powershell-service-wrapper.ps1"
Set-Content -Path $WrapperPath -Value $WrapperScript -Encoding UTF8
Write-Log "PowerShell wrapper script created"

# Step 4: Create scheduled task
Write-Host ""
Write-Host "[STEP 4] Creating PowerShell scheduled task..." -ForegroundColor Green

$PowerShellArgs = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$WrapperPath`" -LogPath `"$LogFile`" -AppPath `"$AppExe`""
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $PowerShellArgs
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 5)

try {
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -Force | Out-Null
    Write-Host "✓ PowerShell task created successfully" -ForegroundColor Green
    Write-Log "Scheduled task created successfully"
} catch {
    Write-Host "ERROR: Failed to create scheduled task: $($_.Exception.Message)" -ForegroundColor Red
    Write-Log "ERROR: Failed to create scheduled task: $($_.Exception.Message)"
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 5: Start the task
Write-Host ""
Write-Host "[STEP 5] Starting PowerShell task..." -ForegroundColor Green

try {
    Start-ScheduledTask -TaskName $TaskName
    Write-Log "Task started successfully"
} catch {
    Write-Host "WARNING: Failed to start task immediately: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Log "WARNING: Failed to start task: $($_.Exception.Message)"
}

# Step 6: Monitor startup
Write-Host ""
Write-Host "[STEP 6] Monitoring startup (30 seconds)..." -ForegroundColor Green

for ($i = 1; $i -le 15; $i++) {
    Start-Sleep -Seconds 2
    
    $AppProcess = Get-Process -Name "pos-middleware" -ErrorAction SilentlyContinue
    if ($AppProcess) {
        Write-Host "✓ Application is running via PowerShell Task!" -ForegroundColor Green
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "INSTALLATION SUCCESSFUL!" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "The Lucrum POS Middleware is now running via PowerShell Task Scheduler." -ForegroundColor Yellow
        Write-Host "This method provides the highest reliability and bypasses ALL service issues." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Task Details:" -ForegroundColor White
        Write-Host "- Name: $TaskName" -ForegroundColor Gray
        Write-Host "- Trigger: System startup" -ForegroundColor Gray
        Write-Host "- Auto-restart: Yes (every 5 minutes)" -ForegroundColor Gray
        Write-Host "- Run as: SYSTEM account" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Application URLs:" -ForegroundColor White
        Write-Host "- HTTP API: http://localhost:8081" -ForegroundColor Gray
        Write-Host "- WebSocket: ws://localhost:8080" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Management Commands:" -ForegroundColor White
        Write-Host "- Start:  Start-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
        Write-Host "- Stop:   Stop-Process -Name 'pos-middleware' -Force" -ForegroundColor Gray
        Write-Host "- Status: Get-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
        Write-Host "- Remove: Unregister-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Log Files:" -ForegroundColor White
        Write-Host "- PowerShell Wrapper: $LogFile" -ForegroundColor Gray
        Write-Host "- Application: $InstallPath\logs\app.log" -ForegroundColor Gray
        Write-Host ""
        
        Write-Log "Installation completed successfully"
        Read-Host "Press Enter to continue"
        exit 0
    }
    
    Write-Host "Waiting for startup... ($i/15)" -ForegroundColor Yellow
}

# Check task status if startup failed
Write-Host ""
Write-Host "========================================" -ForegroundColor Red
Write-Host "CHECKING TASK STATUS" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red

$Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($Task) {
    Write-Host "Task State: $($Task.State)" -ForegroundColor Yellow
    
    $TaskInfo = Get-ScheduledTaskInfo -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($TaskInfo) {
        Write-Host "Last Run Time: $($TaskInfo.LastRunTime)" -ForegroundColor Yellow
        Write-Host "Last Result: $($TaskInfo.LastTaskResult)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "TROUBLESHOOTING:" -ForegroundColor White
Write-Host "1. Check PowerShell wrapper log: $LogFile" -ForegroundColor Gray
Write-Host "2. Run Task Scheduler (taskschd.msc) and look for '$TaskName'" -ForegroundColor Gray
Write-Host "3. Try manual start: Start-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
Write-Host "4. Check Windows Event Viewer" -ForegroundColor Gray
Write-Host ""

Write-Log "Installation completed with warnings - manual verification needed"
Read-Host "Press Enter to continue"