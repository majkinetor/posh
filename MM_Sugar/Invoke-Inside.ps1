
<# .SYNOPSIS
    Execute script in given directory or given files directory
#>
function Invoke-Inside ($dir, $script) {
    if (Test-Path $dir -PathType Leaf) { $dir = Split-Path $dir -Parent }
    pushd $dir; & $script; popd
}

sal in Invoke-Inside
