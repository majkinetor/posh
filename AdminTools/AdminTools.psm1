. $PSScriptRoot\Set-EnvironmentVariable.ps1
. $PSScriptRoot\Start-ElevatedProcess.ps1

Set-Alias import Import-Module
Export-ModuleMember -Function * -Alias *
