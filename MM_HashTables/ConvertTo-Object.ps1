<# .SYNOPSIS
    Converts hashtable to PSCustomObject so that cmdlets that require objects can be used.

   .EXAMPLE
    @{prop1='val1'; prop2='val2'} | o | select -expand prop1
#>
function ConvertTo-Object {
    param( [Parameter(ValueFromPipeline=$true)] [hashtable] $Hash)
    New-Object PSCustomObject -Property $Hash
}

Set-Alias o ConvertTo-Object
