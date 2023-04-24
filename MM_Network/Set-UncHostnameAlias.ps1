function Set-UncHostnameAlias($UncPath) {
    if (!(Get-Module -ListAvailable PsHosts)) { throw "PsHosts module must be installed. Install-Module PsHosts" }

    $remote_hostname = $UncPath -split '\\' | ? {$_} | select -First 1
    $remote_alias    = (Split-Path -Leaf $MyInvocation.ScriptName) -replace '.ps1$'

    $hostEntry = Get-HostEntry $remote_alias* -ea 0 | ? { $_.Comment -eq $remote_hostname } | select -First 1
    if (!$hostEntry) {
        $remote_alias += (Get-HostEntry $remote_alias*).Count + 1
        Write-Verbose "Adding alias $remote_alias => $remote_hostname"
        $remote_ip = Test-Connection -ComputerName $remote_hostname -Count 1  | % IPV4Address | % IPAddressToString
        Add-HostEntry -Name $remote_alias -Address $remote_ip -Force -Comment $remote_hostname | Out-Null
    } else {
        $remote_alias =  $hostEntry.Name
        Write-Verbose "Using $remote_hostname alias: $remote_alias"
    }

    $UncPath.Replace("\\$remote_hostname", "\\$remote_alias")
}
