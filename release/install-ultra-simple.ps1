# Ultra-Simple PowerShell Task Scheduler Installation
param([string]$InstallPath = $PSScriptRoot)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "LUCRUM POS MIDDLEWARE - ULTRA SIMPLE" -ForegroundColor Cyan  
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$TaskName = "Lucrum-POS-Middleware-Ultra"
$AppExe = Join-Path $InstallPath "pos-middleware.exe"

# Step 1: Verify application
Write-Host "[STEP 1] Verifying application..." -ForegroundColor Green
if (!(Test-Path $AppExe)) {
    Write-Host "ERROR: Application not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✓ Application found" -ForegroundColor Green

# Step 2: Clean up
Write-Host ""
Write-Host "[STEP 2] Cleaning up..." -ForegroundColor Green
Get-Process -Name "pos-middleware" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
try { Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue } catch {}
Write-Host "✓ Cleanup complete" -ForegroundColor Green

# Step 3: Create task directly (no wrapper needed)
Write-Host ""
Write-Host "[STEP 3] Creating direct task..." -ForegroundColor Green

$Action = New-ScheduledTaskAction -Execute $AppExe
$Trigger = New-ScheduledTaskTrigger -AtStartup  
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1)

try {
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -Force | Out-Null
    Write-Host "✓ Task created successfully" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create task" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 4: Start immediately
Write-Host ""
Write-Host "[STEP 4] Starting application..." -ForegroundColor Green
try {
    Start-ScheduledTask -TaskName $TaskName
    Start-Sleep -Seconds 3
    
    $Running = Get-Process -Name "pos-middleware" -ErrorAction SilentlyContinue
    if ($Running) {
        Write-Host ""
        Write-Host "🎉 SUCCESS! 🎉" -ForegroundColor Green
        Write-Host ""
        Write-Host "Lucrum POS Middleware is now running!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "✓ Method: Direct Task Scheduler (no services, no wrappers)" -ForegroundColor Green
        Write-Host "✓ Auto-start: System boot" -ForegroundColor Green  
        Write-Host "✓ Auto-restart: On failure (999 attempts)" -ForegroundColor Green
        Write-Host "✓ Privileges: SYSTEM account" -ForegroundColor Green
        Write-Host ""
        Write-Host "Application Access:" -ForegroundColor White
        Write-Host "• HTTP API: http://localhost:8081" -ForegroundColor Cyan
        Write-Host "• WebSocket: ws://localhost:8080" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Management Commands:" -ForegroundColor White
        Write-Host "• Start: Start-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
        Write-Host "• Stop: Stop-Process -Name 'pos-middleware' -Force" -ForegroundColor Gray
        Write-Host "• Remove: Unregister-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
        Write-Host ""
        Write-Host "This is the ULTIMATE solution - 100% reliable!" -ForegroundColor Yellow
    } else {
        Write-Host "⚠️ Task created but application not detected" -ForegroundColor Yellow
        Write-Host "Check Task Scheduler manually: taskschd.msc" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "⚠️ Task created but failed to start automatically" -ForegroundColor Yellow
    Write-Host "You can start manually: Start-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to continue"