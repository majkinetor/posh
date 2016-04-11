# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 11-Apr-2016.

<#
.SYNOPSIS
    Get stored TFS credential from the Windows Credential Manager. If none is available, create and store one.
#>
function Get-TFSStoredCredential {
    [CmdletBinding()]
    param()

    if ($tfs.root_url -eq $null) { throw 'You must set $tfs.root_url in order to get stored credentials' }
    if (!(gmo -ListAvailable CredentialManager -ea 0)) {  Write-Warning 'CredentialManager module is not available'; return }

    try {
        Write-Verbose "Trying to get storred credentials for '$($tfs.root_url)'"
        $cred = Get-StoredCredential -Target $tfs.root_url
    } catch { }

    if ($cred -eq $null) { New-TFSCredential -Store }
    else { Write-Verbose 'Stored credentials retrieved' }

    $cred
}
