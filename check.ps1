################################################################################
# Project: tommyvange/printer-driver-management-scripts
# File: check.ps1
# Developer: Tommy Vange Rød
# License: GPL 3.0 License
#
# This file is part of "Printer Driver Management Scripts".
#
# "Printer Driver Management Scripts" is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.html#license-text>.
################################################################################

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
