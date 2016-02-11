<#
.SYNOPSIS
    Execute script in given directory or given files directory
.EXAMPLE
    PS> in c:\windows ls

    Executes the ls command in the given directory without changing the current directory.

.EXAMPLE
    PS> in c:\windows\notepad.exe ls

    If the directory is a file, the script will execute within its parent.
#>
function Invoke-Inside ($dir, $script) {
    if (Test-Path $dir -PathType Leaf) { $dir = Split-Path $dir -Parent }
    pushd $dir; & $script; popd
}

sal in Invoke-Inside
