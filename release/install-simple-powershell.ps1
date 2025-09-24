# Simple PowerShell Task Scheduler Installation for Lucrum POS Middleware
param(
    [string]$InstallPath = $PSScriptRoot
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "LUCRUM POS MIDDLEWARE - SIMPLE POWERSHELL TASK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$TaskName = "Lucrum-POS-Middleware-Simple"
$AppExe = Join-Path $InstallPath "pos-middleware.exe"

# Step 1: Verify application
Write-Host "[STEP 1] Verifying application..." -ForegroundColor Green
if (!(Test-Path $AppExe)) {
    Write-Host "ERROR: pos-middleware.exe not found at $AppExe" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✓ Application found" -ForegroundColor Green

# Step 2: Clean up existing
Write-Host ""
Write-Host "[STEP 2] Cleaning up existing installations..." -ForegroundColor Green
Get-Process -Name "pos-middleware" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
try {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
} catch {}

# Step 3: Create simple wrapper script
Write-Host ""
Write-Host "[STEP 3] Creating simple wrapper..." -ForegroundColor Green
$WrapperContent = @"
# Simple PowerShell wrapper
param([string]$AppPath = "$AppExe")

while ($true) {
    try {
        $process = Start-Process -FilePath $AppPath -WindowStyle Hidden -PassThru
        $process.WaitForExit()
        if ($process.ExitCode -eq 0) { break }
        Start-Sleep -Seconds 10
    } catch {
        Start-Sleep -Seconds 10
    }
}
"@

$WrapperPath = Join-Path $InstallPath "simple-wrapper.ps1"
$WrapperContent | Out-File -FilePath $WrapperPath -Encoding UTF8

# Step 4: Create scheduled task
Write-Host ""
Write-Host "[STEP 4] Creating scheduled task..." -ForegroundColor Green
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$WrapperPath`""
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable

try {
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -Force | Out-Null
    Write-Host "✓ Task created successfully" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to create task: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 5: Start the task
Write-Host ""
Write-Host "[STEP 5] Starting task..." -ForegroundColor Green
try {
    Start-ScheduledTask -TaskName $TaskName
    Start-Sleep -Seconds 5
    
    # Check if application is running
    $AppRunning = Get-Process -Name "pos-middleware" -ErrorAction SilentlyContinue
    if ($AppRunning) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "SUCCESS! INSTALLATION COMPLETE" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Lucrum POS Middleware is now running via PowerShell Task Scheduler!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Application URLs:" -ForegroundColor White
        Write-Host "- HTTP API: http://localhost:8081" -ForegroundColor Gray
        Write-Host "- WebSocket: ws://localhost:8080" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Management:" -ForegroundColor White
        Write-Host "- Start: Start-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
        Write-Host "- Stop: Stop-Process -Name 'pos-middleware' -Force" -ForegroundColor Gray
        Write-Host "- Remove: Unregister-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
    } else {
        Write-Host "Task created but application may not be running yet." -ForegroundColor Yellow
        Write-Host "Check Task Scheduler for '$TaskName'" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Task created but failed to start: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to continue"