@{
    RootModule           = 'HistoryNinja.psm1'
    ModuleVersion        = '1.1.0'
    CompatiblePSEditions = @('Desktop','Core')
    GUID                 = 'f4000a9f-9285-465b-bfbd-8c662aece0f7'
    Author               = 'Joshua Kelley'
    CompanyName          = 'CrowdStrike'
    Copyright            = '(c) Joshua Kelley. All rights reserved.'
    Description          = 'PowerShell module for retrieving and parsing browser history files.'
    HelpInfoURI          = 'https://github.com/CrowdStrike/psfalcon/wiki'
    PowerShellVersion    = '5.1'
    # RequiredAssemblies   = @('System.Net.Http')
    # ScriptsToProcess     = @('Class/Class.ps1')
    FunctionsToExport    = @(
      # HistoryNinja Functions
      'Get-HistoryNinja'
    )
    CmdletsToExport      = @()
    VariablesToExport    = '*'
    AliasesToExport      = @()
    PrivateData          = @{
        PSData = @{
            Tags         = @('HistoryNinja', 'BrowserHistory', 'Browser', 'History', 'Chrome', 'Firefox', 'Edge')
            LicenseUri   = 'https://github.com/JCKelley-CYBR/HistoryNinja/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/JCKelley-CYBR/HistoryNinja'
            # IconUri      = 'https://raw.githubusercontent.com/crowdstrike/psfalcon/master/icon.png'
            # ReleaseNotes = 'https://github.com/crowdstrike/psfalcon/releases/tag/2.2.4'
        }
    }
}