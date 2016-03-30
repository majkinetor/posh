# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 30-Mar-2016.

<#
.SYNOPSIS
    Create/import build definition

.NOTE
    Build definition property "revision" must point to the latest one in order for import to succeed.
#>
function New-BuildDefinition {
    [CmdletBinding()]
    param (
        [string] $JsonFile
    )

    if (!(Test-Path $JsonFile)) {throw "File doesn't exist: $JsonFile" }

    $uri = "$proj_uri/_apis/build/definitions?api-version=" + $tfs.api_version
    Write-Verbose "URI: $uri"

    $body = gc $JsonFile -Raw -ea Stop
    $r = Invoke-RestMethod -Uri $uri -Method Post -Credential $tfs.credential -Body $body -ContentType 'application/json'
    $r
}
