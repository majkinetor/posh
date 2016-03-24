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

Export-ModuleMember -Alias * -Variable tfs
. "$PSScriptRoot\_globals.ps1"

