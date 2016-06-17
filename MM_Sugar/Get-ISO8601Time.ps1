<# .SYNOPSIS
    Get current time in format ISO8601 yyyy-MM-ddTHH-mm-ss
#>
function Get-ISO8601Time([switch]$fs) {[DateTime]::Now.ToString("s").Replace(':','-')}
sal now Get-ISO8601Time
