# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 11-Apr-2016.

<#
.SYNOPSIS
    Get the TFS build definitions
#>
function Get-TFSBuildDefinitions {
    [CmdletBinding()]
    param (
        #Return raw data instead of the table
        [switch]$Raw
    )
    check_credential

    $uri = "$proj_uri/_apis/build/definitions?api-version=" + $tfs.api_version
    Write-Host "URI: $uri"

    $r = Invoke-RestMethod -Uri $uri -Method Get -Credential $tfs.credential
    if ($Raw) { return $r.value }

    $props = 'name', 'id', 'revision',
             @{ N='author' ; E={ $_.authoredBy.displayname } },
             @{ N='edit url'    ; E={ "$proj_uri/_build#definitionId=" + $_.id + "&_a=simple-process" }}
    $r.value | select -Property $props
}
