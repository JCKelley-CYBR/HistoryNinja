        __  ___      __                      _   ___         _      
       / / / (_)____/ /_____  _______  __   / | / (_)___    (_)___ _
      / /_/ / / ___/ __/ __ \/ ___/ / / /  /  |/ / / __ \  / / __ `/
     / __  / (__  ) /_/ /_/ / /  / /_/ /  / /|  / / / / / / / /_/ / 
    /_/ /_/_/____/\__/\____/_/   \__, /  /_/ |_/_/_/ /_/_/ /\__,_/  
                                /____/                /___/         
        BY: Joshua C. Kelley
        VERSION: 1.0.3


![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/HistoryNinja.svg?style=for-the-badge)
![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/HistoryNinja.svg?style=for-the-badge)
![GitHub commits since latest release (by date)](https://img.shields.io/github/commits-since/JCKelley-CYBR/HistoryNinja/latest.svg?style=for-the-badge)
[![License](https://img.shields.io/github/license/JCKelley-CYBR/HistoryNinja.svg?style=for-the-badge)](LICENSE)
![GitHub issues](https://img.shields.io/github/issues/JCKelley-CYBR/HistoryNinja.svg?style=for-the-badge)
[![CodeFactor](https://www.codefactor.io/repository/github/jckelley-cybr/historyninja/badge/main)](https://www.codefactor.io/repository/github/jckelley-cybr/historyninja/overview/main)

## Description
This script parses browser history files and extracts page titles, URLs, and timestamps. It also parses the history file for download history, returning the file path, timestamp, and size of the downloaded item. 

## Requirements
* PowerShell 5.0 or higher
  * May or may not work on PowerShell 4.0 or lower.
* [PSSQLite](https://www.powershellgallery.com/packages/PSSQLite/1.1.0)
  * Supports PowerShell 2.0 and higher.
  * `PS> Install-Module -Name PSSQLite`

## Installation
### PS Gallery Installation
#### 1. Open a PowerShell console and run the following command to install the module:
   * `PS> Install-Module -Name HistoryNinja`
    * This will install the module from the [PowerShell Gallery](https://www.powershellgallery.com/packages/HistoryNinja/) and the dependencies.
### Manual Installation
#### 1. Download the latest release of: [HistoryNinja.psm1](HistoryNinja.psm1) script.
#### 2. Unzip the contents of the archive. You should have a folder named `HistoryNinja` with the following files:
   * `HistoryNinja.psd1` - This is the module manifest.
   * `HistoryNinja.psm1` - This is the module.
   * `README.md` - This file you are currently reading.
#### 3. Copy the `HistoryNinja` folder to one of the following locations:
   * `$env:PSModulePath` - any of these folders will do.
#### 4. Open a PowerShell console and run the following command to import the module:
   * `PS> Import-Module HistoryNinja`
     * Next, check the module's help: `PS> Get-HistoryNinja -h`

## Compatibility
This module has been tested on the following browsers:
* Chrome
* Firefox
* Edge

The module will *likely* work on other **electron/chromium** based browsers, but has not been tested.

## Usage
```powershell
PS C:\> Get-HistoryNinja -b <browser name> -u <username> -o <output file type>
```

The use of -u requires the command also to include a -b parameter, and vice versa -b requires the command also to include a -u parameter.

```powershell
PS C:\> Get-HistoryNinja -p <Path> -d <From Date> -o <output file type>
```


## Parameters
| Parameter | Description |
|-----------|-------------|
| -p | Set path of history file to parse. |
| -d | Set history from date. |
| -u | Username of the user to parse. |
| -b | Browser to parse. Currently, only Chrome is supported. |
| -dl | Output browser download history. |
| -o | Output file type. Currently, only CSV, TXT, and JSON are supported. |
| -h | Displays this help message. |
| -a | Displays the author of the script. |
| -v | Displays the version of the script. |
| -s | Silent. Suppresses all output to the console. Except for results when -o is not specified.|

## License
This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details

