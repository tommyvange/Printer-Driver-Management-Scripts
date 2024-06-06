param (
    [string]$DriverName = "Canon Generic Plus PCL6",
    [bool]$Logging = $false
)

# Path to configuration file
$configFilePath = "$PSScriptRoot\config.json"

# Initialize configuration variable
$config = $null

# Check if configuration file exists and load it
if (Test-Path $configFilePath) {
    $config = Get-Content -Path $configFilePath | ConvertFrom-Json
}

# Use parameters from the command line or fall back to config file values
if (-not $DriverName) { $DriverName = $config.DriverName }
if (-not $Logging -and $config.Logging -ne $null) { $Logging = $config.Logging }

# Validate that all parameters are provided
if (-not $DriverName) { Write-Error "DriverName is required but not provided."; exit 1 }

# Determine log file path
$logFilePath = "$env:TEMP\check_driver_log_${DriverName}.txt"

# Start transcript logging if enabled
if ($Logging) {
    Start-Transcript -Path $logFilePath
}

function Check-PrinterDriver {
    param (
        [string]$DriverName
    )

    $drivers = Get-PrinterDriver
    $driver = $drivers | Where-Object { $_.Name -eq $DriverName }

    if ($driver) {
        Write-Output "Detected"
        exit 0
    } else {
        Write-Output "NotDetected"
        exit 1
    }
}

try {
    Check-PrinterDriver -DriverName $DriverName
} catch {
    Write-Output "Error: $_"
    exit 1
} finally {
    # Stop transcript logging if enabled
    if ($Logging) {
        Stop-Transcript
    }
}
