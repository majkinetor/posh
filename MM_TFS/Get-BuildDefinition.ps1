function Get-BuildDefinition($Id, [switch]$Raw, [switch]$Export) {

    if ($Id -eq $null) { throw "Resource with that name doesn't exist" }
    if ($Id.GetType() -eq [string]) { $Id = Get-BuildDefinitions | ? name -eq $Id | select -Expand id }

    $uri = "$proj_uri/_apis/build/definitions/$($Id)?api-version=" + $tfs.api_version
    $r = Invoke-RestMethod -Uri $uri -Method Get -Credential $tfs.credential
    if ($Raw) { return $r }

    $res = $r # | select name, type, quality, queue, Build, Triggers, Options, Variables, RetentionRules, Repository
    if ($Export) {
        $res | ConvertTo-Json -Depth 100 | Out-File ("{0}-{1}.json" -f $tfs.project, $r.Name) -Encoding UTF8
    } else { $res }
}
