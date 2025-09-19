# PowerShell Service Installer for POS Middleware
# Run as Administrator: powershell -ExecutionPolicy Bypass -File install-service.ps1

param(
    [string]$ServiceName = "POS-Middleware",
    [string]$DisplayName = "POS Middleware Service",
    [string]$Description = "Lucrum POS Middleware - Handles communication between POS systems and KDS applications"
)

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$exePath = Join-Path $scriptPath "pos-middleware.exe"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "    PowerShell Service Installer" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if executable exists
if (-not (Test-Path $exePath)) {
    Write-Host "ERROR: pos-middleware.exe not found at: $exePath" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Executable found: $exePath" -ForegroundColor Green

try {
    # Stop existing service if running
    Write-Host "Stopping existing service if running..." -ForegroundColor Yellow
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    # Remove existing service if it exists
    $existingService = Get-WmiObject -Class Win32_Service -Filter "Name='$ServiceName'" -ErrorAction SilentlyContinue
    if ($existingService) {
        Write-Host "Removing existing service..." -ForegroundColor Yellow
        $existingService.Delete() | Out-Null
        Start-Sleep -Seconds 2
    }

    # Create new service using WMI (more reliable than New-Service)
    Write-Host "Creating service with WMI..." -ForegroundColor Yellow
    $serviceClass = Get-WmiObject -Class Win32_Service -List
    $result = $serviceClass.Create(
        $exePath,           # PathName
        $ServiceName,       # Name
        $DisplayName,       # DisplayName
        16,                 # ServiceType (OwnProcess)
        2,                  # StartMode (Automatic)
        1,                  # ErrorControl (Normal)
        $null,              # LoadOrderGroup
        $null,              # LoadOrderGroupDependencies
        "LocalSystem"       # ServiceStartName
    )

    if ($result.ReturnValue -eq 0) {
        Write-Host "✓ Service created successfully!" -ForegroundColor Green
        
        # Set service description
        Write-Host "Setting service description..." -ForegroundColor Yellow
        sc.exe description $ServiceName $Description | Out-Null
        
        # Configure failure recovery
        Write-Host "Configuring failure recovery..." -ForegroundColor Yellow
        sc.exe failure $ServiceName reset=300 actions=restart/30000/restart/60000/restart/120000 | Out-Null
        
        # Set service to delayed auto start (more reliable)
        Write-Host "Setting delayed auto start..." -ForegroundColor Yellow
        sc.exe config $ServiceName start=delayed-auto | Out-Null
        
        # Start the service
        Write-Host "Starting service..." -ForegroundColor Yellow
        Start-Service -Name $ServiceName -ErrorAction Stop
        
        # Wait a moment and check status
        Start-Sleep -Seconds 5
        $service = Get-Service -Name $ServiceName
        
        if ($service.Status -eq "Running") {
            Write-Host "================================================" -ForegroundColor Green
            Write-Host "        SUCCESS!" -ForegroundColor Green
            Write-Host "================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "Service Name: $ServiceName" -ForegroundColor White
            Write-Host "Status: $($service.Status)" -ForegroundColor Green
            Write-Host "API URL: http://localhost:8081" -ForegroundColor White
            Write-Host "WebSocket URL: ws://localhost:8080" -ForegroundColor White
            Write-Host ""
            Write-Host "Testing API in 3 seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds 3
            
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:8081/api/v1/health" -TimeoutSec 10 -ErrorAction Stop
                Write-Host "✓ API is responding!" -ForegroundColor Green
                Write-Host "Response: $($response.Content)" -ForegroundColor Cyan
            } catch {
                Write-Host "⚠ API not responding yet, but service is running" -ForegroundColor Yellow
                Write-Host "It may take a moment to fully initialize" -ForegroundColor Yellow
            }
        } else {
            Write-Host "⚠ Service created but not running. Status: $($service.Status)" -ForegroundColor Yellow
            Write-Host "Check Windows Event Viewer for errors" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "✗ Failed to create service. Error code: $($result.ReturnValue)" -ForegroundColor Red
        switch ($result.ReturnValue) {
            1 { Write-Host "Error: Not Supported" -ForegroundColor Red }
            2 { Write-Host "Error: Access Denied" -ForegroundColor Red }
            3 { Write-Host "Error: Dependent Services Running" -ForegroundColor Red }
            4 { Write-Host "Error: Invalid Service Control" -ForegroundColor Red }
            5 { Write-Host "Error: Service Cannot Accept Control" -ForegroundColor Red }
            6 { Write-Host "Error: Service Not Active" -ForegroundColor Red }
            7 { Write-Host "Error: Service Request Timeout" -ForegroundColor Red }
            8 { Write-Host "Error: Unknown Failure" -ForegroundColor Red }
            9 { Write-Host "Error: Path Not Found" -ForegroundColor Red }
            10 { Write-Host "Error: Service Already Running" -ForegroundColor Red }
            11 { Write-Host "Error: Service Database Locked" -ForegroundColor Red }
            12 { Write-Host "Error: Service Dependency Deleted" -ForegroundColor Red }
            13 { Write-Host "Error: Service Dependency Failure" -ForegroundColor Red }
            14 { Write-Host "Error: Service Disabled" -ForegroundColor Red }
            15 { Write-Host "Error: Service Logon Failure" -ForegroundColor Red }
            16 { Write-Host "Error: Service Marked For Deletion" -ForegroundColor Red }
            17 { Write-Host "Error: Service No Thread" -ForegroundColor Red }
            18 { Write-Host "Error: Status Circular Dependency" -ForegroundColor Red }
            19 { Write-Host "Error: Status Duplicate Name" -ForegroundColor Red }
            20 { Write-Host "Error: Status Invalid Name" -ForegroundColor Red }
            21 { Write-Host "Error: Status Invalid Parameter" -ForegroundColor Red }
            22 { Write-Host "Error: Status Invalid Service Account" -ForegroundColor Red }
            23 { Write-Host "Error: Status Service Exists" -ForegroundColor Red }
            24 { Write-Host "Error: Service Already Paused" -ForegroundColor Red }
        }
    }
    
} catch {
    Write-Host "✗ PowerShell error occurred: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Management Commands:" -ForegroundColor Cyan
Write-Host "Start:  Start-Service -Name '$ServiceName'" -ForegroundColor White
Write-Host "Stop:   Stop-Service -Name '$ServiceName'" -ForegroundColor White
Write-Host "Status: Get-Service -Name '$ServiceName'" -ForegroundColor White
Write-Host "Remove: Remove-Service -Name '$ServiceName'" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to exit"