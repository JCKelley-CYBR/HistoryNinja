@{
    RootModule           = 'HistoryNinja.psm1'
    ModuleVersion        = '1.0.0'
    CompatiblePSEditions = @('Desktop','Core')
    GUID                 = 'f4000a9f-9285-465b-bfbd-8c662aece0f7'
    Author               = 'Joshua Kelley'
    CompanyName          = 'Me, Myself, and I'
    Copyright            = '(c) Joshua Kelley. All rights reserved.'
    Description          = 'PowerShell module for retrieving and parsing browser history files.'
    HelpInfoURI          = 'https://github.com/JCKelley-CYBR/HistoryNinja#readme'
    PowerShellVersion    = '5.0'
    FunctionsToExport    = @(
      # History Ninja Functions
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
            ReleaseNotes = 'https://github.com/JCKelley-CYBR/HistoryNinja/releases/tag/1.0.0'
        }
    }
}