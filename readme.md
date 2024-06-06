# Printer Driver Management Scripts

These scripts are designed to install and uninstall printer drivers on Windows machines. They can read parameters from the command line, a configuration file (`config.json`), or use default values. If any required parameter is missing and cannot be resolved, the scripts will fail with an appropriate error message.

This repository is licensed under the **[GNU General Public License v3.0 (GPLv3)](LICENSE)**.

Developed by **[Tommy Vange Rød](https://github.com/tommyvange)**.

## Configuration

The scripts use a configuration file (`config.json`) to store default values for the printer driver settings. Here is an example of the configuration file:

``` json
{
	"DriverPath": "./driver/CNP60MA64.INF", 
	"DriverName": "Canon Generic Plus PCL6", 
	"Logging": false
}
```

### Driver Path

The `DriverPath` specified in the configuration file or command line is treated as a relative path from the location of the PowerShell script. This ensures that the scripts can locate the driver files correctly when deployed in different environments, such as through Intune.

For example, if your script is located in `C:\Scripts` and your driver is located in `C:\Scripts\driver\etc\CNP60MA64.INF`, you would set the `DriverPath` to `.\driver\etc\CNP60MA64.INF`.

## Install Script

### Description

The install script adds a printer driver using the specified parameters.

### Usage
To run the add shortcut script, use the following command:

``` powershell
.\install.ps1 -DriverPath "<DriverPath>" -DriverName "<DriverName>" [-Logging]
```

### Parameters
-   `DriverPath`: The path to the printer driver `.INF` file.
-   `DriverName`: The name of the printer driver.
-   [Optional] `Logging`: Enables transcript logging if set.

### Fallback to Configuration File
If a parameter is not provided via the command line, the script will attempt to read it from the `config.json` file. If the parameter is still not available, the script will fail and provide an error message.

### Example
To specify values directly via the command:

``` powershell
.\install.ps1 -DriverPath "./driver/CNP60MA64.INF" -DriverName "Canon Generic Plus PCL6" [-Logging]
```

To use the default values from the configuration file:

``` powershell
.\install.ps1
```

### Script Workflow
1.  Add the printer driver using `pnputil.exe`.
2.  Add the printer driver with PowerShell.

## Uninstall Script

### Description
The uninstall script removes a specified printer driver using the specified parameters.

### Usage
To run the remove shortcut script, use the following command:

``` powershell
.\uninstall.ps1 -DriverPath "<DriverPath>" -DriverName "<DriverName>" [-Logging]
```

### Parameters
-   `DriverPath`: The path to the printer driver `.INF` file.
-   `DriverName`: The name of the printer driver.
-   [Optional] `Logging`: Enables transcript logging if set.

### Fallback to Configuration File
If a parameter is not provided via the command line, the script will attempt to read it from the `config.json` file. If the parameter is still not available, the script will fail and provide an error message.

### Example
To specify values directly via the command:

``` powershell
.\uninstall.ps1 -DriverPath ".\driver\etc\CNP60MA64.INF" -DriverName "Canon Generic Plus PCL6" [-Logging]
```

To use the default values from the configuration file:

``` powershell
.\uninstall.ps1
```

### Script Workflow
1.  Uninstall the printer driver using `pnputil.exe`.
2.  Remove the printer driver with PowerShell.

## Check Printer Driver Script

### Description
The check printer driver script verifies if a specified printer driver exists and outputs "Detected" or "NotDetected". It uses exit codes compatible with Intune: `0` for success (detected) and `1` for failure (not detected).

### Usage
To run the check shortcut script, use the following command:

``` powershell
.\check.ps1 -DriverName "<DriverName>" [-Logging $true]
```

### Parameters
-   `DriverName`: The name of the printer driver to check.
-   [Optional] `Logging`: Enables transcript logging if set.

### Fallback to Configuration File
If a parameter is not provided via the command line, the script will attempt to read it from the `config.json` file. If the parameter is still not available, the script will fail and provide an error message.

### Example
To specify values directly via the command:
``` powershell
.\check.ps1 -DriverName "Canon Generic Plus" [-Logging]
``` 

To use the default values from the configuration file:
``` powershell
.\check.ps1
``` 

### Script Workflow
1.  Check if the driver name is provided.
2.  Start transcript logging if enabled.
3.  Check if the printer driver exists.
4.  Output "Detected" if the driver exists, otherwise output "NotDetected".

## Logging

### Description

All scripts support transcript logging to capture detailed information about the script execution. Logging can be enabled via the `-Logging` parameter or the configuration file.

### How It Works

When logging is enabled, the scripts will start a PowerShell transcript at the beginning of the execution and stop it at the end. This transcript will include all commands executed and their output, providing a detailed log of the script's actions.

### Enabling Logging

Logging can be enabled by setting the `-Logging` parameter when running the script, or by setting the `Logging` property to `true` in the `config.json` file.

### Log File Location

The log files are stored in the temporary directory of the user running the script. The log file names follow the pattern:

-   For the install script: `installation_log_<DriverName>.txt`
-   For the uninstall script: `uninstallation_log_<DriverName>.txt`
-   For the check script: `check_driver_log_<DriverName>.txt`

Example log file paths:

-   `C:\Users\<Username>\AppData\Local\Temp\installation_log_Canon Generic Plus PCL6.txt`
-   `C:\Users\<Username>\AppData\Local\Temp\uninstallation_log_Canon Generic Plus PCL6.txt`
-   `C:\Users\<Username>\AppData\Local\Temp\check_driver_log_Canon Generic Plus PCL6.txt`

**System Account Exception**: When scripts are run as the System account, such as during automated deployments or via certain administrative tools, the log files will be stored in the `C:\Windows\Temp` directory instead of the user's local temporary directory.

### Example
To enable logging via the command line:

``` powershell
.\install.ps1 -DriverPath ".\driver\etc\CNP60MA64.INF" -DriverName "Canon Generic Plus PCL6" -Logging
```

Or by setting the `Logging` property in the configuration file:
``` json
{
	"DriverPath": "./driver/CNP60MA64.INF", 
	"DriverName": "Canon Generic Plus PCL6", 
	"Logging": true
}
```
## Error Handling

All scripts include error handling to provide clear messages when parameters are missing or actions fail. If any required parameter is missing and cannot be resolved, the scripts will fail with an appropriate error message.

## Notes
-   Ensure that you have the necessary permissions to add and remove printer drivers on the machine where these scripts are executed.
-   The scripts assume that the printer driver specified is already available at the specified path.

## Troubleshooting

If you encounter any issues, ensure that all parameters are correctly specified and that the printer driver is available at the provided path. Check the error messages provided by the scripts for further details on what might have gone wrong.

# GNU General Public License v3.0 (GPLv3)

The  **GNU General Public License v3.0 (GPLv3)**  is a free, copyleft license for software and other creative works. It ensures your freedom to share, modify, and distribute all versions of a program, keeping it free software for everyone.

Full license can be read [here](LICENSE) or at [gnu.org](https://www.gnu.org/licenses/gpl-3.0.en.html#license-text).

## Key Points:

1.  **Freedom to Share and Change:**
    
    -   You can distribute copies of GPLv3-licensed software.
    -   Access the source code.
    -   Modify the software.
    -   Create new free programs using parts of it.
2.  **Responsibilities:**
    
    -   If you distribute GPLv3 software, pass on the same freedoms to recipients.
    -   Provide the source code.
    -   Make recipients aware of their rights.
3.  **No Warranty:**
    
    -   No warranty for this free software.
    -   Developers protect your rights through copyright and this license.
4.  **Marking Modifications:**
    
    -   Clearly mark modified versions to avoid attributing problems to previous authors.

