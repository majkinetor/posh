# Export functions that start with capital letter, others are private
# Include file names that start with capital letters, ignore other


$pre = ls Function:\*
ls "$PSScriptRoot\*.ps1" | ? { $_.Name -cmatch '^[A-Z]+' } | % { . $_  }
$post = ls Function:\*
$funcs = compare $pre $post | select -Expand InputObject | select -Expand Name
$funcs | ? { $_ -cmatch '^[A-Z]+'} | % { Export-ModuleMember -Function $_ }

function d ( $t, $f ) { if ($t) {$t} else {$f} }
$tfs = [ordered]@{
    root_url    = $tfs.root_url
    collection  = d $tfs.collection 'DefaultCollection'
    project     = $tfs.project
    api_version = d $tfs.api_version '2.0'
    credential  = $tfs.credential
}

if (($tfs.credential -eq $null) -and (gmo -ListAvailable CredentialManager -ea 0)) {
    try { $cred = Get-StoredCredential -Target $tfs.root_url } catch {}
    if ($cred -eq $null) {
        $user_default = "$Env:USERDOMAIN\$Env:USERNAME"
        $user = Read-Host -Prompt "TFS Username ($user_default)"
        if ($user.Trim() -eq '') { $user = $user_default }
        $pass = Read-Host -Prompt "TFS Password" -AsSecureString
        $cred = New-Object System.Net.NetworkCredential('', $pass)
        New-StoredCredential -Target $tfs.root_url -UserName $user -Password $cred.password -Persist LOCAL_MACHINE | Out-Null
        Remove-Variable cred
    }
    try { $tfs.credential = Get-StoredCredential -Target $tfs.root_url } catch {}
} else { Write-Warning 'CredentialManager module is not available' }

Export-ModuleMember -Alias * -Variable tfs
. "$PSScriptRoot\_globals.ps1"

