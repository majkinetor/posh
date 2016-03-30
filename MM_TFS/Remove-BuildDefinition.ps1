# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 30-Mar-2016.

<#
.SYNOPSIS
    Remove the TFS build definition
#>
function Remove-BuildDefinition {
    [CmdletBinding()]
    param(
        #Build defintion id [int] or name [string]
        $Id
    )

    if ($Id.GetType() -eq [string]) { $Id = Get-BuildDefinitions | ? name -eq $Id | select -Expand id }
    if ($Id -eq $null) { throw "Resource with that name doesn't exist" }
    Write-Verbose "Build definition id: $Id"

    $uri = "$proj_uri/_apis/build/definitions/$($Id)?api-version=" + $tfs.api_version
    Write-Verobse "URI: $uri"
    $r = Invoke-RestMethod -Uri $uri -Method Delete -Credential $tfs.credential
    $r
}

