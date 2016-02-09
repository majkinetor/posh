# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 09-Feb-2016.

#requires -version 2.0

<#
.SYNOPSIS
    Open regedit at given location

.EXAMPLE
    PS HKLM:\SOFTWARE\> gi . | Open-Regedit

    Open regedit at HKLM:\Software by value from pipeline

.EXAMPLE
    PS HKLM:\SOFTWARE\> Open-Regedit $pwd

    Open regedit at HKLM:\Software via argument

.NOTES
    Original by http://goo.gl/5aQgtd

#>
function Open-Regedit {

    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipeLine=$true, ValueFromPipeLineByPropertyName=$true)]
        [Alias('Name')]
        [string]$Key
    )

    $Replacements = @{':'='' # Remove PowerShell syntax
                    'HKCU'='HKEY_CURRENT_USER'
                    'HKLM'='HKEY_LOCAL_MACHINE'
                    'HKU'='HKEY_USERS'
                    'HKCC'='HKEY_CURRENT_CONFIG'
                    'HKCR'='HKEY_CLASSES_ROOT'}
    $Replacements.Keys | % { $key = $key.ToUpper().Replace($_, $Replacements[$_]) }

    $Key =  $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Key)
    Write-Verbose "Open $Key"
    sp HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit -Name LastKey -Value $Key -Force
    regedit -m # Open new instance
}

Set-Alias regjump Open-Regedit
