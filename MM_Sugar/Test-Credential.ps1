<#
.SYNOPSIS
    Takes a PSCredential object and validates it against the domain (or local machine, or ADAM instance).

.LINK
    https://serverfault.com/a/286003/23290
#>
function Test-Credential {
    param(
        # A PSCredential object with the username/password to test. Typically this is generated using the Get-Credential cmdlet.
        [parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [PSCredential] $Credential,

        # An optional parameter specifying what type of credential this is. Possible values are 'Domain','Machine',and 'ApplicationDirectory.' The default is 'Domain'.
        [validateset('Domain','Machine','ApplicationDirectory')]
        [string] $Context = 'Domain'
    )

    begin {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::$Context)
    }

    process {
        $DS.ValidateCredentials( $Credential.UserName, $Credential.GetNetworkCredential().Password )
    }
}

<#
.SYNOPSIS
    Takes a PSCredential object and validates it against the domain

.DESCRIPTION
    Sometimes Test-Credential method doesn't work

.LINK
    https://serverfault.com/a/286003/23290
#>

function Test-ADCredential {
    param(
        # A PSCredential object with the username/password to test. Typically this is generated using the Get-Credential cmdlet.
        [parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [PSCredential] $Credential
    )

    $currentDomain = "LDAP://" + ([ADSI]"").distinguishedName
    $domain = New-Object System.DirectoryServices.DirectoryEntry($currentDomain, $Credential.UserName, $Credential.GetNetworkCredential().Password)
    $null -ne $domain.name
}