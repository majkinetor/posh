function Set-UncHostnameAlias($UncPath, $RemoteAlias) {
    if (!(Get-Module -ListAvailable PsHosts)) { throw "PsHosts module must be installed. Install-Module PsHosts" }
    if (!($RemoteAlias)) {
        if (!$MyInvocation.ScriptName) { throw "Either run this function within a script or provide RemoteAlias parameter" }
        $RemoteAlias = (Split-Path -Leaf $MyInvocation.ScriptName) -replace '.ps1$'
    }

    $remote_hostname = $UncPath -split '\\' | ? {$_} | select -First 1

    $hostEntry = Get-HostEntry $RemoteAlias* -ea 0 | ? { $_.Comment -eq $remote_hostname } | select -First 1
    if (!$hostEntry) {
        $RemoteAlias += (Get-HostEntry $RemoteAlias*).Count + 1
        Write-Verbose "Adding alias $RemoteAlias => $remote_hostname"
        $remote_ip = Test-Connection -ComputerName $remote_hostname -Count 1 -ErrorAction Stop | % IPV4Address | % IPAddressToString
        Add-HostEntry -Name $RemoteAlias -Address $remote_ip -Force -Comment $remote_hostname | Out-Null
    } else {
        $RemoteAlias =  $hostEntry.Name
        Write-Verbose "Using $remote_hostname alias: $RemoteAlias"
    }

    $UncPath.Replace("\\$remote_hostname", "\\$RemoteAlias")
}
