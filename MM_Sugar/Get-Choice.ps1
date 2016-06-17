# Author: Miodrag Milic <miodrag.milic@gmail.com>
# Last Change: 17-Jun-2016.

#requires -version 3

<#
.SYNOPSIS
    Easily create choice

.EXAMPLE
    Get-Choice

    Create default choice with 'yes', 'no', and 'cancel' options and default message 'Are you sure?'.

.EXAMPLE
    choice -Message 'Do you want to keep the files?' -Choices "&Keep", "&Delete", "St&op", "&Skip"

    Create a choice with custom message and 4 custom options

.EXAMPLE

    choice -Message 'Do you want to keep the files?' -Choices ([ordered]@{"&Keep" = "Keep the files on the disk"; "&Delete" = "Delete the files from the disk"})

    Create a choice with help messages 
.OUTPUT
    [String]
#>
function Get-Choice {
    [CmdletBinding()]
    param(
        #Choice title
        [string]$Title,
        #Choice message
        [string]$Message = 'Are you sure?',
        #Choice options, array or [ordered]hashable
        $Choices = @("&Yes", "&No", "&Cancel"),
        #Index of the default option
        [int]$Default=0
    )

    if (@([System.Collections.Specialized.OrderedDictionary],[object[]]) -notcontains $Choices.GetType()) { throw "Invalid parameter type for Choices - must be ordered [HashTable] or [Object[]]" }
    if ($Choices.Length -eq 0) { throw "Invalid parameter Choices - empty" }

    if ($Choices.GetType() -eq [object[]]) {
        $Choices = $Choices | ? {$_.Trim()} #remove invalid options
        $Choices | % {$c=@()} {$c += New-Object System.Management.Automation.Host.ChoiceDescription $_, $_.Replace('&','') }
    } else {
        $Choices = $Choices.GetEnumerator() | ? {$_.Name.Trim()} #remove invalid options
        $Choices.GetEnumerator() | % {$c=@()} {$c += New-Object System.Management.Automation.Host.ChoiceDescription $_.Name, $_.Value }
        $Choices = $Choices.key
    }

    $options = [System.Management.Automation.Host.ChoiceDescription[]]$c
    $res = $host.ui.PromptForChoice($Title, $Message, $options, $Default)

    $Choices -split '\n'| select -Index $res | % { $_.Replace('&','') }
}

sal choice Get-Choice
