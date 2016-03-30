# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 30-Mar-2016.

<#
.SYNOPSIS
    Get the TFS build list
#>
function Get-Builds {
    [CmdletBinding()]
    param (
        #Return raw data insted of the table
        [switch] $Raw,
        #Number of latest builds to return, by default 15.
        [int] $First=15
    )

    $uri = "$proj_uri/_apis/build/builds?api-version=" + $tfs.api_version
    Write-Verbose "URI: $uri"

    $r = Invoke-RestMethod -Uri $uri -Method Get -Credential $tfs.credential
    if ($Raw) { return $r.value }

    $props = 'buildNumber', 'result',
             @{ N='Start time'   ; E={ (get-date $_.startTime).ToString($time_format) }},
             @{ N='Duration (m)' ; E={ [math]::round( ((get-date $_.finishTime) - (get-date $_.startTime)).TotalMinutes, 1)}}

    $r.value | select -Property $props -First $First | ft -au
}
