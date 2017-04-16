<#

.SYNOPSIS
    Edit multiple files in $Env:EDITOR

.EXAMPLE
    PS> dir ..\*.txt | ed  "my file.txt"

    Edit all text files from the parent directory along with "my file.txt" from current dir.
#>
function Edit-File () {
    $f = $input + $args | % { """$($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( $_ ))""" }
    iex ". '$Env:EDITOR' $f"
}


sal ed Edit-File
sal edit Edit-File
