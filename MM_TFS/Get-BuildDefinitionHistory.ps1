# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 30-Mar-2016.

<#
.SYNOPSIS
    Get the build definition history
#>
function Get-BuildDefinitionHistory{
    [CmdletBinding()]
    param(
        # Build definition history id [int] or name [string]
        $Id,
        # Return raw data instead of the table
        [switch]$Raw
    )

    if ($Id.GetType() -eq [string]) { $Id = Get-BuildDefinitions | ? name -eq $Id | select -Expand id }
    if ($Id -eq $null) { throw "Build definition with that name or id doesn't exist" }
    Write-Verbose "Build definition history id: $Id"

    $uri = "$proj_uri/_apis/build/definitions/$($Id)/revisions?api-version=" + $tfs.api_version
    Write-Verbose "URI: $uri"

    $r = Invoke-RestMethod -Uri $uri -Method Get -Credential $tfs.credential
    if ($Raw) { return $r.value }

    $props = 'revision', 'comment', 'changeType',
             @{ N='date';       E={ (get-date $_.changedDate).tostring($time_format)} },
             @{ N='changed by'; E={ $_.changedBy.displayName } }

    $r.value | select -Property $props | sort revision -Desc | ft -au
}
