
function Get-Project($Id) {

    if ($Id.GetType() -eq [string]) { $Id = Get-Projects | ? name -eq $Id | select -Expand id }

    $uri = "$collection_uri/_apis/projects/$($Id)?includeCapabilities=true&api-version=" + $tfs.api_version
    $r = Invoke-RestMethod -Uri $uri -Method Get -Credential $tfs.credential
    $r
}
