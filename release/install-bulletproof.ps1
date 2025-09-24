# BULLETPROOF PowerShell Task Scheduler Installation
param([string]$InstallPath = $PSScriptRoot)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "LUCRUM POS MIDDLEWARE - BULLETPROOF" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$TaskName = "Lucrum-POS-Middleware-Bulletproof"
$AppExe = Join-Path $InstallPath "pos-middleware.exe"

# Step 1: Verify application
Write-Host "[STEP 1] Verifying application..." -ForegroundColor Green
if (!(Test-Path $AppExe)) {
    Write-Host "ERROR: Application not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Application found" -ForegroundColor Green

# Step 2: Clean up existing
Write-Host ""
Write-Host "[STEP 2] Cleaning up..." -ForegroundColor Green
Get-Process -Name "pos-middleware" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
try {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
} catch {
    # Ignore cleanup errors
}
Write-Host "Cleanup complete" -ForegroundColor Green

# Step 3: Create scheduled task
Write-Host ""
Write-Host "[STEP 3] Creating task..." -ForegroundColor Green

$Action = New-ScheduledTaskAction -Execute $AppExe
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1)

try {
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -Force | Out-Null
    Write-Host "Task created successfully" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create task" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 4: Start the task
Write-Host ""
Write-Host "[STEP 4] Starting application..." -ForegroundColor Green
try {
    Start-ScheduledTask -TaskName $TaskName
    Start-Sleep -Seconds 5
    
    $Running = Get-Process -Name "pos-middleware" -ErrorAction SilentlyContinue
    if ($Running) {
        Write-Host ""
        Write-Host "SUCCESS! APPLICATION IS RUNNING!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Lucrum POS Middleware is now active!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Details:" -ForegroundColor White
        Write-Host "- Method: Direct Task Scheduler" -ForegroundColor Gray
        Write-Host "- Auto-start: System boot" -ForegroundColor Gray
        Write-Host "- Auto-restart: On failure" -ForegroundColor Gray
        Write-Host "- Privileges: SYSTEM account" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Access URLs:" -ForegroundColor White
        Write-Host "- HTTP API: http://localhost:8081" -ForegroundColor Cyan
        Write-Host "- WebSocket: ws://localhost:8080" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Management:" -ForegroundColor White
        Write-Host "- Start: Start-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
        Write-Host "- Stop: Stop-Process -Name 'pos-middleware' -Force" -ForegroundColor Gray
        Write-Host "- Remove: Unregister-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
        Write-Host ""
        Write-Host "INSTALLATION COMPLETE - 100% RELIABLE!" -ForegroundColor Yellow
    } else {
        Write-Host "Task created but application not detected yet" -ForegroundColor Yellow
        Write-Host "Check Task Scheduler manually: taskschd.msc" -ForegroundColor Yellow
        Write-Host "Or try: Start-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Task created but failed to start automatically" -ForegroundColor Yellow
    Write-Host "Manual start: Start-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to continue"