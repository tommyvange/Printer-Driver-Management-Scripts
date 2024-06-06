param (
    [string]$DriverPath,
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
if (-not $DriverPath) { $DriverPath = $config.DriverPath }
if (-not $DriverName) { $DriverName = $config.DriverName }
if (-not $Logging -and $config.Logging -ne $null) { $Logging = $config.Logging }

# Combine DriverPath with PSScriptRoot to get the absolute path
$DriverPath = Join-Path -Path $PSScriptRoot -ChildPath $DriverPath

# Validate that all parameters are provided
if (-not $DriverPath) { Write-Error "DriverPath is required but not provided."; exit 1 }
if (-not $DriverName) { Write-Error "DriverName is required but not provided."; exit 1 }

# Determine log file path
$logFilePath = "$env:TEMP\installation_log_${DriverName}.txt"

# Start transcript logging if enabled
if ($Logging) {
    Start-Transcript -Path $logFilePath
}

try {
    # Add the printer driver
    pnputil.exe /add-driver $DriverPath /install
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Error: Failed to add printer driver."
        exit 1
    }

    # Add the printer driver with PowerShell
    Add-PrinterDriver -Name $DriverName
    if ($?) {
        Write-Output "Printer driver installed successfully."
        exit 0
    } else {
        Write-Output "Error: Failed to add printer driver with Add-PrinterDriver cmdlet."
        exit 1
    }
} catch {
    Write-Output "Error: $_"
    exit 1
} finally {
    # Stop transcript logging if enabled
    if ($Logging) {
        Stop-Transcript
    }
}
