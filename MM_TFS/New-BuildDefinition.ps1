
function New-BuildDefinition($JsonFile) {

    $uri = "$proj_uri/_apis/build/definitions?api-version=" + $tfs.api_version

    $body = gc $JsonFile -Raw -ea Stop
    $r = Invoke-RestMethod -Uri $uri -Method Post -Credential $tfs.credential -Body $body -ContentType 'application/json'
    $r
}
