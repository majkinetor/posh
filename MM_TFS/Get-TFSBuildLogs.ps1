# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 11-Apr-2016.

<#
.SYNOPSIS
    Get the unified build logs for the TFS build

.EXAMPLE
    PS> Get-TFSBuildLogs

    Returns logs of the latest build

.EXAMPLE
    PS> Get-TFSBuildLogs 250

    Returns logs of the build by id
#>
function Get-TFSBuildLogs{
    [CmdletBinding()]
    param(
        #Id of the build, by default the latest build is used.
        [string]$Id
    )
    check_credential

    if ($Id -eq '') { $Id = Get-TFSBuilds -Raw | select -First 1 -Expand id }
    if ($Id -eq $null) { throw "Can't find latest build or there are no builds" }
    Write-Verbose "Build id: $Id"

    $uri = "$proj_uri/_apis/build/builds/$Id/logs?api-version=" + $tfs.api_version
    Write-Verbose "Logs URI: $uri"

    $r = Invoke-RestMethod -Uri $uri -Method Get -Credential $tfs.credential

    $lines = @()
    $root_server_name = $tfs.root_url -split '/' | select -Index 2
    foreach ( $url in $r.value.url ) {
        #TFS might return non FQDM so its best to replace its server name with the one user specified
        $new_url = $url -split '/'
        $new_url[2] = $root_server_name
        $new_url = $new_url -join '/'

        Write-Verbose "Log URI: $new_url"
        $l = Invoke-RestMethod -Uri $new_url -Method Get -Credential $tfs.credential
        $lines += $l.value -replace '\..+?Z'
        $lines += "="*150
    }
    $lines
}
