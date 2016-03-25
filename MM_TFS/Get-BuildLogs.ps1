function Get-BuildLogs($Id=$null) {
    if ($Id -eq $null) { $Id = get-builds -Raw | select -First 1 -Expand id }
    if ($Id -eq $null) { throw "Can't find latest build or there are no builds" }

    $uri = "$proj_uri/_apis/build/builds/$Id/logs?api-version=" + $tfs.api_version
    $r = Invoke-RestMethod -Uri $uri -Method Get -Credential $tfs.credential

    $lines = @()
    $root_server_name = $tfs.root_url -split '/' | select -Index 2
    foreach ( $url in $r.value.url ) {
        #TFS might return non FQDM so its best to replace its server name with the one user specified
        $new_url = $url -split '/'
        $new_url[2] = $root_server_name
        $new_url = $new_url -join '/'

        $l = Invoke-RestMethod -Uri $new_url -Method Get -Credential $tfs.credential
        $lines += $l.value -replace '\..+?Z'
        $lines += "="*150
    }
    $lines
}
