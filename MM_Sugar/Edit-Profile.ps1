<#
.SYNOPSIS
    Edit $PROFILE using $Env:EDITOR
#>
function Edit-Profile {
    mkdir (Split-Path $PROFILE) -force -ea 0
    ed $PROFILE
}

sal edp Edit-Profile
