<# .SYNOPSIS
    Get current time in format ISO8601 yyyy-MM-ddTHH-mm-ss with : of time replaced with -
    so it can be used with Windows filenames
#>
function Get-ISO8601Time([switch]$fs) {[DateTime]::Now.ToString("s").Replace(':','-')}
sal now Get-ISO8601Time
