
function Get-Project($Id) {

    if ($Id.length -ne 36) { $Id = Get-Projects -Raw | ? name -eq $Id | select -Expand id }
    if ($Id -eq $null) { throw "Can't find project with that name or id" }

    $uri = "$collection_uri/_apis/projects/$($Id)?includeCapabilities=true&api-version=" + $tfs.api_version
    $r = Invoke-RestMethod -Uri $uri -Method Get -Credential $tfs.credential
    $r
}
