<#
    Last Change: 10-Feb-2016.
    Author: M. Milic <miodrag.milic@gmail.com>

.SYNOPSIS
    Get the uninstall registry key of the application.

.PARAMETER AppName
    String that is contained within DisplayName property.

.RETURNS
    Registry key or null

#>
function Get-AppliationUninstallKey([string]$AppName)
{
    $local_key       = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    $machine_key     = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    $machine_key6432 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    gp @($machine_key6432, $machine_key, $local_key) -ea 0 | ? { $_.DisplayName -like "*$AppName*" }
}
