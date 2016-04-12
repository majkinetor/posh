# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 12-Apr-2016.

<#
.SYNOPSIS
    Get the build definition

.EXAMPLE
    PS> Get-BuildDefinition Build1

    Get the build definition by name

.EXAMPLE
    PS> Get-BuildDefinition 5 -OutFile .

    Exports the build defintiion to json file in the current directory. '.' is a special value for the file
    to be automatically named as Project-Build_Name.json in the current directory
#>
function Get-TFSBuildDefinition{
    [CmdletBinding()]
    param(
        #Build defintion id [int] or name [string]
        [string]$Id,
        #Return raw data instead of table
        [switch]$Raw,
        #Export the build to the specified JSON file
        [string]$OutFile
    )
    check_credential

    if ($Id.GetType() -eq [string]) { $Id = Get-TFSBuildDefinitions | ? name -eq $Id | select -Expand id }
    if ($Id -eq $null) { throw "Resource with that name doesn't exist" }
    Write-Verbose "Build definition id: $Id"

    $uri = "$proj_uri/_apis/build/definitions/$($Id)?api-version=" + $tfs.api_version
    Write-Verbose "URI: $uri"

    $r = Invoke-RestMethod -Uri $uri -Method Get -Credential $tfs.credential
    if ($Raw) { return $r }

    $res = $r # | select name, type, quality, queue, Build, Triggers, Options, Variables, RetentionRules, Repository
    if ($OutFile) {
        if ($OutFile -eq '.') { $OutFile = "{0}-{1}.json" -f $tfs.project, $r.Name }
        $res | ConvertTo-Json -Depth 100 | Out-File $OutFile -Encoding UTF8
    } else { $res }
}
