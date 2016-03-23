function Get-BuildDefinitions([switch]$Raw)
{
    $uri = "$proj_uri/_apis/build/definitions?api-version=" + $tfs.api_version
    $r = Invoke-RestMethod -Uri $uri -Method Get -Credential $tfs.credential
    if ($Raw) { return $r }

    $props = 'name', 'id', 'revision',
             @{ N='author' ; E={ $_.authoredBy.displayname } },
             @{ N='edit url'    ; E={ "$proj_uri/_build#definitionId=" + $_.id + "&_a=simple-process" }}
    $r.value | select -Property $props
}
