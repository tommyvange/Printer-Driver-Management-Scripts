################################################################################
# Repository: tommyvange/Printer-Driver-Management-Scripts
# File: install.ps1
# Developer: Tommy Vange Rød
# License: GPL 3.0 License
#
# This file is part of "Printer-Driver-Management-Scripts".
#
# "Printer-Driver-Management-Scripts" is free software: you can redistribute it and/or modify
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
    [string]$DriverPath,
    [string]$DriverName,
    [switch]$Logging
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

# Pre-authorizing the driver certificate
if ($config.CertificateManagementInstall -eq $true) {
    Write-Output "Certificate management install is enabled. Proceeding with certificate pre-authorization."

    # Locate the driver catalog file (.cat)
    $driverInfPath = $config.DriverPath
    $driverCatFile = Get-ChildItem -Path (Split-Path -Parent $driverInfPath) -Filter "*.cat" | Select-Object -First 1

    if ($null -ne $driverCatFile) {
        Write-Output "Found catalog file: $($driverCatFile.FullName). Extracting certificate."

        # Extract the certificate from the catalog file
        $signature = Get-AuthenticodeSignature -FilePath $driverCatFile.FullName

        if ($signature.SignerCertificate -ne $null) {
            Write-Output "Certificate found: $($signature.SignerCertificate.Subject). Adding to TrustedPublisher store."

            # Add the certificate to the TrustedPublisher store
            $trustedPublisherStore = Get-Item -Path Cert:\LocalMachine\TrustedPublisher
            $trustedPublisherStore.Open("ReadWrite")
            $trustedPublisherStore.Add($signature.SignerCertificate)
            $trustedPublisherStore.Close()

            Write-Output "Certificate added to TrustedPublisher store successfully."
        } else {
            Write-Output "No valid certificate found in $($driverCatFile.FullName)."
            exit 1
        }
    } else {
        Write-Output "No catalog (.cat) file found for the driver. Cannot extract certificate."
        exit 1
    }
} else {
    Write-Output "Certificate management install is disabled. Skipping certificate pre-authorization."
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
