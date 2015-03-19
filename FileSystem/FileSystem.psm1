$name = gi $MyInvocation.MyCommand | select -expand BaseName
ls "$PSScriptRoot\$name\*.ps1" | % { . $_ }

Export-ModuleMember -Function * -Alias *
