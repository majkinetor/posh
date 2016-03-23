
function Get-Projects([switch]$Raw ) {
    $uri = "$collection_uri/_apis/projects?api-version=" + $tfs.api_version
    $r = Invoke-RestMethod -Uri $uri -Method Get -Credential $tfs.credential
    if ($Raw) { return $r }

    $res = $r.value | select name, description, revision, id
    $res | ft -auto
}
