$time_format    = "yy-MM-dd HH\:mm"
$collection_uri = "{0}/{1}" -f $tfs.root_url, $tfs.collection
$proj_uri       = "{0}/{1}" -f $collection_uri, $tfs.project

function check_credential() {
    [CmdletBinding()]
    param()

    if ($tfs.Credential) {
        Write-Verbose "TFS Credential: $($tfs.Credential.UserName)"
        return
    }

    Write-Verbose 'No credentials specified, trying Windows Credential Manager'
    $tfs.Credential = Get-TFSSToredCredential
}
