ls "$PSScriptRoot\*.ps1" | % { . $_ }

Export-ModuleMember -Function connect-vpn, disconnect-vpn -Alias *
