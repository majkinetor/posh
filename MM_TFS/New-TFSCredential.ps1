# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 11-Apr-2016.

<#
.SYNOPSIS
    Create and optionaly store the TFS credentials
#>
function New-TFSCredential {
    [CmdletBinding()]
    param(
        # TFS Credentials.
        [PSCredential] $Credential,

        # Store credential in the Windows Credential Valut
        [switch] $Store
    )

    Write-Verbose "Get TFS credentials for '$($tfs.root_url)'"
    if ($Credential -eq $null) { $Credential = Get-Credential }
    if ($Credential -eq $null) { Write-Warning 'Aborted'; return }

    if (!$Store) { return }
    if (!(gmo -ListAvailable CredentialManager -ea 0)) {  Write-Warning 'CredentialManager module is not available'; return $Credential }

    if ($tfs.root_url -eq $null) { throw 'You must set $tfs.root_url in order to store credentials' }

    Write-Verbose "Storing credential for target '$($tfs.root_url)'"
    New-StoredCredential -Target $tfs.root_url -UserName $Credential.UserName -Password $Credential.GetNetworkCredential().Password -Persist LOCAL_MACHINE | Out-Null

    return $Credential
}
