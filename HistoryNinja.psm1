###################
# History Ninja - HistoryParser.ps1
# Author: Joshua C. Kelley
# Version: 1.1
# Last Updated: 2023-02-14
# Creation Date: 2023-01-04
# Description: This script will locate the history file for the current user and return the path to the file.
# This is the module file for the History Ninja PowerShell Module.
###################
# Write a function to parse the Chrome History File and return the URL and time it was visited.

###################
# Change Log:
# Version 1.0 - 2023-01-04: Initial Creation
# - Added the ability to search for a specific date range. Added the ability to search for a specific path.
# - Added the ability to search for a specific username. Added the ability to search for a specific browser.
# - Added the ability to search for a specific URL. Added the ability to search download history.
# - Added the ability to output the results to a CSV, TXT, and JSON file.
# Version 1.1 - 2023-02-14: Added History Ninja Banner
# - Added the History Ninja Banner to the script.
# - Update output to use current working directory.
###################

Import-Module PSSQLite

###################
# Global Script Variables
###################

# Script Attributes
$versionOut = "1.1"
$authorOut = "Joshua C. Kelley"

# Banner Function  
$banner = @"

        __  ___      __                      _   ___         _      
       / / / (_)____/ /_____  _______  __   / | / (_)___    (_)___ _
      / /_/ / / ___/ __/ __ \/ ___/ / / /  /  |/ / / __ \  / / __ `/
     / __  / (__  ) /_/ /_/ / /  / /_/ /  / /|  / / / / / / / /_/ / 
    /_/ /_/_/____/\__/\____/_/   \__, /  /_/ |_/_/_/ /_/_/ /\__,_/  
                                /____/                /___/         

        BY: $authorOut
        VERSION: $versionOut

"@

###################
# Description: This function will determine if the user folder exists for the specified user.
# Parameters: $username
# Returns: $found (boolean)
###################
function Get-Userpath {
    param (
        [Parameter(Mandatory=$true)]
        [string]$username
    )
    # $userpath = Get-ChildItem -path C:\Users -Directory | Select-Object Name, FullName, LastWriteTime | Where-Object {$_.Name -eq $u}
    return Test-path "C:\Users\$username"
}

###################
# Description: This function will convert the date range to a number of seconds since 01/01/1601
# Parameters: $date
# Returns: $temp (number of seconds since 01/01/1601)
###################
function Get-TimeRange {
    param (
        [Parameter(Mandatory=$true)]
        [string]$date
    )
    $conversion = (New-TimeSpan -Start (Get-Date "01/01/1601") -End (Get-Date $date)).TotalSeconds
    $conversion = $conversion * 1000000
    return [bigint]$conversion
}

###################
# Description: This function will convert the DB time to a the actual datetime in CST.
# Parameters: $date
# Returns: $temp (datetime)
###################
function Set-TimeCov {
    param (
        [Parameter(Mandatory=$true)]
        [string]$date
    )
    $conversion = $date/1000000
    $conversion = ((Get-Date 01.01.1601).AddSeconds($conversion)).ToString("yyyy-MM-dd HH:mm:ss")
    $tzone = Get-TimeZone -Id "Central Standard Time"
    $conversion = [System.DateTime]::Parse($conversion).AddHours($tzone.BaseUtcOffset.Hours)
    return $conversion
}

###################
# Description: This function will return the contents of the history file.
# Parameters: $fileLocation
# Returns: $history (array of history records)
###################
function Get-History {
    param (
        [Parameter(Mandatory=$true)]
        [string]$fileLocation
    )

    if (Test-path $fileLocation) {
        if ($dl)
        {
            $history = Invoke-SqliteQuery -path $fileLocation -Query "SELECT * FROM downloads"
            $arr = @()
            foreach ($record in $history) {
                $record.start_time = Set-TimeCov -date $record.start_time
                $record.end_time = Set-TimeCov -date $record.end_time
                $arr += $record
            }
        }
        else
        {
            $history = Invoke-SqliteQuery -path $fileLocation -Query "SELECT * FROM urls"
            $arr = @()
            foreach ($record in $history) {
                $record.last_visit_time = Set-TimeCov -date $record.last_visit_time
                $arr += $record
            }
        }    
    }
    else {
        Write-Output "History File Not Found: $fileLocation"
    }
    return $arr
}

###################
# Description: This function will return the contents of the history file after a specified date ($date).
# Parameters: $fileLocation, $date
# Returns: $history (array of history records)
###################
function Get-HistoryDate {
    param (
        [Parameter(Mandatory=$true)]
        [string]$fileLocation,
        [Parameter(Mandatory=$true)]
        [string]$date
    )

    if (Test-path $fileLocation) {
        if ($dl)
        {
            $history = Invoke-SqliteQuery -path $fileLocation -Query "SELECT * FROM downloads WHERE start_time > $date"
            $arr = @()
            foreach ($record in $history) {
                $start = $record.start_time/1000000
                $end = $record.end_time/1000000
                $record.start_time = ((Get-Date 01.01.1601).AddSeconds($start)).ToString("yyyy-MM-dd HH:mm:ss")
                $record.end_time = ((Get-Date 01.01.1601).AddSeconds($end)).ToString("yyyy-MM-dd HH:mm:ss")
                $tzone = Get-TimeZone -Id "Central Standard Time"
                $record.start_time = [System.DateTime]::Parse($record.start_time).AddHours($tzone.BaseUtcOffset.Hours)
                $record.end_time = [System.DateTime]::Parse($record.end_time).AddHours($tzone.BaseUtcOffset.Hours)
                $arr += $record
            }
        }
        else
        {
            $history = Invoke-SqliteQuery -path $fileLocation -Query "SELECT * FROM urls WHERE last_visit_time > $date"
            $arr = @()
            foreach ($record in $history) {
                $temp = $record.last_visit_time/1000000
                $record.last_visit_time = ((Get-Date 01.01.1601).AddSeconds($temp)).ToString("yyyy-MM-dd HH:mm:ss")
                $tzone = Get-TimeZone -Id "Central Standard Time"
                $record.last_visit_time = [System.DateTime]::Parse($record.last_visit_time).AddHours($tzone.BaseUtcOffset.Hours)
                $arr += $record
            }
        }
    }
    else {
        Write-Output "History File Not Found: $fileLocation"
    }

    return $arr
}

###################
# Description: This function will return the contents of the history file for Firefox.
# Parameters: $fileLocation
# Returns: $arr (array of history records)
###################
function Get-HistoryFirefox {
    param (
        [Parameter(Mandatory=$true)]
        [string]$fileLocation
    )
    $foundFileLocation = Get-ChildItem -Path $fileLocation
    if ($null -eq $foundFileLocation -or $foundFileLocation -eq "") {
        Write-Output "History File Not Found: $fileLocation"
        return
    }
    else
    {
        $fileLocation = $foundFileLocation.FullName
        if (Test-path $fileLocation) {
            if ($dl)
            {
                $history = Invoke-SqliteQuery -path $fileLocation -Query "SELECT * FROM moz_annos"
                $arr = @()
                foreach ($record in $history) {
                    $record.dateAdded = Set-DateTimeff -epoch $record.dateAdded
                    $record.lastModified = Set-DateTimeff -epoch $record.lastModified
                    $arr += $record
                }
            }
            else
            {
                $history = Invoke-SqliteQuery -path $fileLocation -Query "SELECT * FROM moz_places"
                $arr = @()
                foreach ($record in $history) {
                    $record.last_visit_date = Set-DateTimeff -epoch $record.last_visit_date
                    $arr += $record
                }
            }
        }
        else {
            Write-Output "History File Not Found: $fileLocation"
        }
    }
    return $arr
}

###################
# Description: This function will return the contents of the history file for Firefox after a specified date ($date).
# Parameters: $fileLocation, $date
# Returns: $arr (array of history records)
###################
function Get-HistoryFirefoxDate {
    param (
        [Parameter(Mandatory=$true)]
        [string]$fileLocation,
        [Parameter(Mandatory=$true)]
        [string]$date
    )
    $foundFileLocation = Get-ChildItem -Path $fileLocation
    if ($null -eq $foundFileLocation -or $foundFileLocation -eq "") {
        Write-Output "History File Not Found: $fileLocation"
        return
    }
    else
    {
        $fileLocation = $foundFileLocation.FullName
        if ($dl)
        {
            $history = Invoke-SqliteQuery -path $fileLocation -Query "SELECT * FROM moz_annos WHERE dateAdded > $date"
            $arr = @()
            foreach ($record in $history) {
                $record.dateAdded = Set-DateTimeff -epoch $record.dateAdded
                $record.lastModified = Set-DateTimeff -epoch $record.lastModified
                $arr += $record
            }
        }
        else
        {
            $history = Invoke-SqliteQuery -path $fileLocation -Query "SELECT * FROM moz_places WHERE last_visit_date > $date"
            $arr = @()
            foreach ($record in $history) {
                $record.last_visit_date = Set-DateTimeff -epoch $record.last_visit_date
                $arr += $record
            }
        }
    }
    return $arr
}

###################
# Description: This function will return the conversion of epoch time to a date.
# Parameters: $epoch
# Returns: $date (datetime)
###################
function Set-DateTimeff {
    param (
        [Parameter(Mandatory=$true)]
        [string]$epoch
    )
    $epoch = $epoch/1000000
    $date = (([System.DateTimeOffset]::FromUnixTimeSeconds($epoch)).DateTime).ToString()
    $tzone = Get-TimeZone -Id "Central Standard Time"
    $date = [System.DateTime]::Parse($date).AddHours($tzone.BaseUtcOffset.Hours)
    return $date
}

###################
# Description: This function will return the conversion of a date to epoch time.
# Parameters: $date
# Returns: $epoch (datetime)
###################y
function Get-EpochTimeff {
    param (
        [Parameter(Mandatory=$true)]
        [string]$date
    )
    $epoch = Get-Date $date -UFormat %s
    $epoch = [int]$epoch*1000000
    $epoch = [bigint]$epoch
    return $epoch
}

function Get-HelpOutput {
    Write-Output "
        Description:
            This script will locate the history file for the current user and return the path to the file. 
            If the path is provided, the script will return the contents of the history file. 
            If a date is provided, the script will return the contents of the history file after the specified date.

        Usage: .\HistoryParser.ps1
            Example (1): Get-HistoryNinja -p 'C:\Users\<User ID>\AppData\Local\Google\Chrome\User Data\Default\History' -d <from date>
                Returns the contents of the history file, from the provided path, after 12/31/2022.

            Example (2): Get-HistoryNinja -u <User ID> -d 12/31/2022 -b chrome
                Returns the contents of the history file (chrome), for the provided user and browser, after 12/31/2022.

            Example (3): Get-HistoryNinja -u <User ID> -b firefox -dl
                Returns the contents of the download history file (firefox), for the provided user and browser.

        Parameters:
            -p: path to the history file. If not specified, the script will attempt to locate the history file for the current user.
            -d: Date range to filter the history file. If not specified, the script will return the entire history file.
            -u: Username of the user. If not specified, the script will attempt to locate the history file for the current user.
            -b: Browser to search for. If not specified, the script will search, and no path is provided the script will end.
            -dl: Download history. If not specified, the script will search for browsing history.
            -o: Output file. Type the format after the option. 
                Acceptable formats: CSV, TXT, and JSON. 
                The resulting file will be in the current working directory: $pwd
                If not specified, the script will output to the console.
            -h: Help. Displays this help message.
            -a: Author of the script. Displays the author of the script.
            -v: Version of the script. Displays the version of the script.
            -s: Silent. Suppresses all output to the console. 
                Except for results when -o is not specified.
        "
        return
}

###################
# Description: This function will return the contents of the history file - Main function of the module.
# Params: $p, $d, $u, $b, $h, $a, $v, $o, $s
# $p: User provided path to the history file.
# $d: FROM date to search for.
# $u: The username to search for.
# $b: The browser to search for.
# $d: Switches query to downloads table in the History File.
# $h: Display the help context.
# $a: Display the author.
# $v: Display the version.
# $o: Output file. Type the format after the option. Accepts CSV, TXT, and JSON.
# $s: Suppress all output to the console.
# Returns: $history (array), or $history is output to a file (-o). 
###################

function Get-HistoryNinja {
    param (
        [Parameter(Mandatory=$false)]
        [string]$p, # Path
        [Parameter(Mandatory=$false)]
        [string]$d, # Date
        [Parameter(Mandatory=$false)]
        [string]$u, # Username
        [Parameter(Mandatory=$false)]
        [string]$b, # Browser
        [Parameter(Mandatory=$false)]
        [switch]$dl, # Downloads
        [Parameter(Mandatory=$false)]
        [switch]$h, # Help
        [Parameter(Mandatory=$false)]
        [switch]$a, # Author
        [Parameter(Mandatory=$false)]
        [switch]$v, # Version
        [Parameter(Mandatory=$false)]
        [string]$o, # Output
        [Parameter(Mandatory=$false)]
        [switch]$s # Silent
    )

    # Browser paths
    $chrome = "C:\Users\$u\AppData\Local\Google\Chrome\User Data\Default\History"
    $firefox = "C:\Users\$u\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite"
    $edge = "C:\Users\$u\AppData\Local\Microsoft\Edge\User Data\Default\History"

    if (!$s) {
        $banner
    }
    # Set the error action preference to silently continue
    $ErrorActionPreference= 'silentlycontinue'

    if ($h)
    {
        Get-HelpOutput
    }
    if ($a)
    {
        Write-Output "Author: $authorOut"
        return
    }
    if ($v)
    {
        Write-Output "Version: $versionOut"
        return
    }

    # History Parser
    if ($u -eq '')
    {
        $temp = Split-Path $p -leaf
        if ($temp -eq "places.sqlite") {
            if ($d -eq '') {
                $History = Get-HistoryFirefox -fileLocation $p
            }
            else {
                $out = Get-EpochTimeff -date $d
                $History = Get-HistoryFirefoxDate -fileLocation $p -date $out
            }
        }
        else{
            if ($d -eq '') {
                $History = Get-History -fileLocation $p
            }
            else {
                $out = Get-TimeRange -date $d
                $History = Get-HistoryDate -fileLocation $p -date $out
            }
        }
    }
    else {
        $userpath = Get-Userpath -username $u
        if ($userpath) {
            if ($b -ne '')
            {
                if ($d -eq '')
                {
                    if ($b.ToLower() -eq "chrome") {
                        $History = Get-History -fileLocation $chrome
                    }
                    elseif ($b.ToLower() -eq "firefox") {
                        $History = Get-HistoryFirefox -fileLocation $firefox
                    }
                    elseif ($b.ToLower() -eq "edge") {
                        $History = Get-History -fileLocation $edge
                    }
                    else {
                        Write-Output "Browser not found. Use -browser Chrome, Firefox, or Edge."
                    }
                }
                else {
                    if ($b.ToLower()  -eq "chrome") {
                        $out = Get-TimeRange -date $d
                        $History = Get-HistoryDate -fileLocation $chrome -date $out
                    }
                    elseif ($b.ToLower()  -eq "firefox") {
                        $out = Get-EpochTimeff -date $d
                        $History = Get-HistoryFirefoxDate -fileLocation $firefox -date $out
                    }
                    elseif ($b.ToLower()  -eq "edge") {
                        $out = Get-TimeRange -date $d
                        $History = Get-HistoryDate -fileLocation $edge -date $out
                    }
                    else {
                        Write-Output "Browser not found. Use -b Chrome, Firefox, or Edge."
                    }
                }
            }
            else {
                Write-Output "Path (-p) or Browser (-b) is not specified. Use -b Chrome, Firefox, or Edge. Or use -p to specify the path to the history file."
            }
        }
        else {
            Write-Output "User C:\Users\$u not found."
        }
    }

    # Output Handler
    if ($o -ne '') {
        if ($o.ToLower() -eq 'csv') {
            $History | Export-Csv -Path "$pwd\History.csv" -NoTypeInformation
            if (!$s) {
                Write-Host "Output saved to $pwd\History.csv" -ForegroundColor Green
            }
        }
        elseif ($o.ToLower() -eq 'txt') {
            $History | Out-File -FilePath "$pwd\History.txt"
            if (!$s) {
                Write-Host "Output saved to $pwd\History.txt" -ForegroundColor Green
            }
        }
        elseif ($o.ToLower() -eq 'json') {
            $History | ConvertTo-Json | Out-File -FilePath "$pwd\History.json"
            if (!$s) {
                Write-Host "Output saved to $pwd\History.json" -ForegroundColor Green
            }
        }
        else
        {
            Write-Host "Output format not found. Use -o CSV, TXT, or JSON. Or do not use -o, to output to the console" -ForegroundColor Red
        }
    }
    else {
        if (!$s) {
            $History
        }
    }
}

