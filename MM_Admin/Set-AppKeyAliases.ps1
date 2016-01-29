<#
    Last Change: 2016-01-21.
    Author: M. Milic <miodrag.milic@gmail.com>

.SYNOPSIS
    Creates Powershell aliases for executables listed in the App Paths registry key

.EXAMPLE
    Set-AppKeyAliases *> $null

    Use this in $profile to set aliases for new shell

.NOTES
    https://msdn.microsoft.com/en-us/library/windows/desktop/ee872121(v=vs.85).aspx#appPaths
#>
function Set-AppKeyAliases(){
    [CmdletBinding()]
    param()

    $AppPathKey = "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths"

    ls "HKLM:\$AppPathKey", "HKCU:\$AppPathKey" -ea 0 | % {
        $name = $_.Name -split '\\' | select -Last 1
        $name = $name -replace '.exe$'

        $path = gp $_.PSPath | select -expand '(default)' -ea 0
        if ($path -ne $null -and $path.StartsWith('"')) { $path = $path.Substring(1, $path.Length-2) }
        if ($path -eq $null -or !(Test-Path $path)) {Write-Warning "Ignoring invalid path for '$name' : '$path'"; return }

        Write-Verbose ("{0} = {1}" -f $name, $path)
        Set-Alias $name $path -Scope global -ea 0 -ErrorVariable err
        if ($err[0].FullyQualifiedErrorId -eq 'AliasNotWritable,Microsoft.PowerShell.Commands.SetAliasCommand') { Write-Warning "Alias not writable: $name" }
    }
}
