<# .SYNOPSIS
    Set current and working directory to the same one.
#>
function Set-WorkingDir([string] $Dir=$pwd) { cd $Dir; [IO.Directory]::SetCurrentDirectory($Dir) }
sal wcd Set-WorkingDir
