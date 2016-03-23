function Get-BuildLogs($Id) {
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
