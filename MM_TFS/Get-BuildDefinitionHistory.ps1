function Get-BuildDefinitionHistory($Id, [switch]$Raw) {
    if ($Id.GetType() -eq [string]) { $Id = Get-BuildDefinitions | ? name -eq $Id | select -Expand id }
    if ($Id -eq $null) { throw "Build definition with that name or id doesn't exist" }

    $uri = "$proj_uri/_apis/build/definitions/$($Id)/revisions?api-version=" + $tfs.api_version
    $r = Invoke-RestMethod -Uri $uri -Method Get -Credential $tfs.credential
    if ($Raw) { return $r }

    $props = 'revision', 'comment', 'changeType',
             @{ N='date';       E={ (get-date $_.changedDate).tostring($time_format)} },
             @{ N='changed by'; E={ $_.changedBy.displayName } }

    $r.value | select -Property $props | sort revision -Desc | ft -au
}
