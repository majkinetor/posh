
function Delete-BuildDefinition($Id) {

    if ($Id.GetType() -eq [string]) { $Id = Get-BuildDefinitions | ? name -eq $Id | select -Expand id }
    if ($Id -eq $null) { throw "Resource with that name doesn't exist" }

    $uri = "$proj_uri/_apis/build/definitions/$($Id)?api-version=" + $tfs.api_version
    $r = Invoke-RestMethod -Uri $uri -Method Delete -Credential $tfs.credential
    $r
}

