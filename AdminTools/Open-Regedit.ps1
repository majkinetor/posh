#Original: http://goo.gl/5aQgtd

function Open-Regedit {

    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipeLine=$true)]
        [string]$Key
    )

    $Replacements = @{':'='' # Remove PowerShell syntax
                    'HKCU'='HKEY_CURRENT_USER'
                    'HKLM'='HKEY_LOCAL_MACHINE'
                    'HKU'='HKEY_USERS'
                    'HKCC'='HKEY_CURRENT_CONFIG'
                    'HKCR'='HKEY_CLASSES_ROOT'}
    $Replacements.Keys | % { $key = $key.ToUpper().Replace($_, $Replacements[$_]) }
    Write-Verbose "Open $Key"
    sp HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\ -Name LastKey -Value $Key -Force
    regedit -m # Open new instance
}
