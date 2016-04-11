# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 11-Apr-2016.

<#
.SYNOPSIS
    Create new TFS project
.NOTE
    Not supported on on-premise TFS
#>
function New-TFSProject($Name, $Description) {
    check_credential

    $uri = "$collection_uri/_apis/projects/?api-version=" + $tfs.api_version
    $uri
    $body = @{
        name = $Name
        description = $Description
        capabilities = @{
            processTemplate = @{ templateName      = 'Agile' }
            versionControl  = @{ sourceControlType = 'Git' }
        }
    }

    $body = $body | ConvertTo-Json
    $r = Invoke-RestMethod -Uri $uri -Method Post -Credential $tfs.credential -Body $body -ContentType 'application/json'
    $r
}
