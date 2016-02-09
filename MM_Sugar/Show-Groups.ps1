function Show-Groups {
    [System.Security.Principal.WindowsIdentity]::GetCurrent().Groups | % {$_.Translate([Security.Principal.NTAccount])} | sort
}
sal groups Show-Groups
