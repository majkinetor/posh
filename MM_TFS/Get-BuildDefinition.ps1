# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 30-Mar-2016.

<#
.SYNOPSIS
    Get the build definition

.EXAMPLE
    PS> Get-BuildDefinition Build1

    Get the build definition by name

.EXAMPLE
    PS> Get-BuildDefinition 5 -Export

    Exports the build defintiion to json file in the current directory
#>
function Get-BuildDefinition{
    [CmdletBinding()]
    param(
        #Build defintion id [int] or name [string]
        [string]$Id,
        #Return raw data instead of table
        [switch]$Raw,
        #Export the build to the file named Poject-BuildName.json
        [switch]$Export
    )

    if ($Id.GetType() -eq [string]) { $Id = Get-BuildDefinitions | ? name -eq $Id | select -Expand id }
    if ($Id -eq $null) { throw "Resource with that name doesn't exist" }
    Write-Verbose "Build definition id: $Id"

    $uri = "$proj_uri/_apis/build/definitions/$($Id)?api-version=" + $tfs.api_version
    Write-Verbose "URI: $uri"

    $r = Invoke-RestMethod -Uri $uri -Method Get -Credential $tfs.credential
    if ($Raw) { return $r }

    $res = $r # | select name, type, quality, queue, Build, Triggers, Options, Variables, RetentionRules, Repository
    if ($Export) {
        $res | ConvertTo-Json -Depth 100 | Out-File ("{0}-{1}.json" -f $tfs.project, $r.Name) -Encoding UTF8
    } else { $res }
}
