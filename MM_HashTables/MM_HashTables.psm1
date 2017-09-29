ls "$PSScriptRoot\*.ps1" | % { . $_ }
Export-ModuleMember -Function * -Alias *
