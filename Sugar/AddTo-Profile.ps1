# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 15-May-2015.

#requires -version 2.0

<#
.SYNOPSIS
    Add Powershell code to the Powershell profile

.DESCRIPTION
    This function implements idempotent way to add a Powershell code to the $PROFILE.
    It will create $PROFILE if it doesn't exist and add the code if its not already there.

.RETURNS
    True if code was added to the $PROFILE, False if $code is already in the $PROFILE.

.EXAMPLE
    AddTo-Profile "Import-Module PSReadLine"
#>
function AddTo-Profile() {
	[CmdletBinding()]
	param(
		# Powershell code to add to the $PROFILE
		[string]$Code,
		# Specify to prepend code. Otherwise code wiill be appended
		[switch]$Prepend
	)
	
	$prof = gc $PROFILE -ea ignore 
	
	if ($prof -like "*$code*") { return $false }
	
	$p = .{
		if ($Prepend)  {$Code} 
		$prof 
		if (!$Prepend) {$Code}
	      }
        
	mkdir -Force (Split-Path -Parent $PROFILE) | out-null	
	sc $PROFILE $p

	return $true
} 
