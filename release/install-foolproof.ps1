param([string]$InstallPath = $PSScriptRoot)

Write-Host "========================================"
Write-Host "LUCRUM POS MIDDLEWARE - FOOLPROOF"
Write-Host "========================================"
Write-Host ""

$TaskName = "Lucrum-POS-Middleware-Foolproof"
$AppExe = Join-Path $InstallPath "pos-middleware.exe"

Write-Host "[STEP 1] Checking application..."
if (!(Test-Path $AppExe)) {
    Write-Host "ERROR: pos-middleware.exe not found!"
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "OK: Application found"

Write-Host ""
Write-Host "[STEP 2] Cleaning up..."
Get-Process -Name "pos-middleware" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
try {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
} catch {
}
Write-Host "OK: Cleanup done"

Write-Host ""
Write-Host "[STEP 3] Creating task..."
$Action = New-ScheduledTaskAction -Execute $AppExe
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable

try {
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -Force | Out-Null
    Write-Host "OK: Task created"
} catch {
    Write-Host "ERROR: Task creation failed"
    Write-Host $_.Exception.Message
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "[STEP 4] Starting..."
try {
    Start-ScheduledTask -TaskName $TaskName
    Start-Sleep -Seconds 5
    
    $Running = Get-Process -Name "pos-middleware" -ErrorAction SilentlyContinue
    if ($Running) {
        Write-Host ""
        Write-Host "SUCCESS! APPLICATION IS RUNNING!"
        Write-Host ""
        Write-Host "Access URLs:"
        Write-Host "- HTTP API: http://localhost:8081"
        Write-Host "- WebSocket: ws://localhost:8080"
        Write-Host ""
        Write-Host "Management:"
        Write-Host "- Start: Start-ScheduledTask -TaskName '$TaskName'"
        Write-Host "- Stop: Stop-Process -Name 'pos-middleware' -Force"
        Write-Host ""
        Write-Host "INSTALLATION COMPLETE!"
    } else {
        Write-Host "Task created but app not running yet"
        Write-Host "Try: Start-ScheduledTask -TaskName '$TaskName'"
    }
} catch {
    Write-Host "Task created but start failed"
    Write-Host "Manual start: Start-ScheduledTask -TaskName '$TaskName'"
}

Write-Host ""
Read-Host "Press Enter to continue"