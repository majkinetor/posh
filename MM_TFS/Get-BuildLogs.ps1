function Get-BuildLogs($Id=$null) {
    if ($Id -eq $null) { $Id = get-builds -Raw | select -First 1 -Expand id }
    if ($Id -eq $null) { throw "Can't find latest build or there are no builds" }

    $uri = "$proj_uri/_apis/build/builds/$Id/logs?api-version=" + $tfs.api_version
    $r = Invoke-RestMethod -Uri $uri -Method Get -Credential $tfs.credential

    $lines = @()
    foreach ( $url in $r.value.url ) {
        $l = Invoke-RestMethod -Uri $url -Method Get -Credential $tfs.credential
        $lines += $l.value -replace '\..+?Z'
        $lines += "="*150
    }
    $lines
}
