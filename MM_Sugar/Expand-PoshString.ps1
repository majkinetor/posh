<# .SYNOPSIS
    Expands powershell string.
   .EXAMPLE
    gc template.ps1 | expand
#>
function Expand-PoshString() {
    [CmdletBinding()]
    param ( [parameter(ValueFromPipeline = $true)] [string] $str)

    "@`"`n$str`n`"@" | iex
}

sal expand Expand-PoshString
