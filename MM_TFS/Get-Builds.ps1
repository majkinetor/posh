function Get-Builds([switch]$Raw, $First=10)
{
    $uri = "$proj_uri/_apis/build/builds?api-version=" + $tfs.api_version

    $r = Invoke-RestMethod -Uri $uri -Method Get -Credential $tfs.credential
    if ($Raw) { return $r.value }

    $props = 'buildNumber', 'result',
             @{ N='Start time'   ; E={ (get-date $_.startTime).ToString($time_format) }},
             @{ N='Duration (m)' ; E={ [math]::round( ((get-date $_.finishTime) - (get-date $_.startTime)).TotalMinutes, 1)}}

    $r.value | select -Property $props -First $First | ft -au
}
