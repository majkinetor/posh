$time_format    = "yy-MM-dd HH\:mm"
$collection_uri = "{0}/{1}" -f $tfs.root_url, $tfs.collection
$proj_uri       = "{0}/{1}" -f $collection_uri, $tfs.project

function check_credential() {
    [CmdletBinding()] param()
    if (($tfs.Credential -ne '') -and ($tfs.Credential -ne $null)) { return }

    Write-Verbose 'No credentials specified, trying store'
    $tfs.Credential = Get-TFSSToredCredential
}
