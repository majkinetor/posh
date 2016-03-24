#requires -version 4.0

Function Test-URI {
<#
.Synopsis
    Test a URI or URL
.Description
    This command will test the validity of a given URL or URI that begins with either http or https. The default behavior is to write a Boolean value to the pipeline. But you can also ask for more detail.

    Be aware that a URI may return a value of True because the server responded correctly. For example this will appear that the URI is valid.

    test-uri -uri http://files.snapfiles.com/localdl936/CrystalDiskInfo7_2_0.zip

    But if you look at the test in detail:

    ResponseUri   : http://files.snapfiles.com/localdl936/CrystalDiskInfo7_2_0.zip
    ContentLength : 23070
    ContentType   : text/html
    LastModified  : 1/19/2015 11:34:44 AM
    Status        : 200

    You'll see that the content type is Text and most likely a 404 page. By comparison, this is the desired result from the correct URI:

    PS C:\> test-uri -detail -uri http://files.snapfiles.com/localdl936/CrystalDiskInfo6_3_0.zip

    ResponseUri   : http://files.snapfiles.com/localdl936/CrystalDiskInfo6_3_0.zip
    ContentLength : 2863977
    ContentType   : application/x-zip-compressed
    LastModified  : 12/31/2014 1:48:34 PM
    Status        : 200

.Example
    PS C:\> test-uri https://www.petri.com
    True
.Example
    PS C:\> test-uri https://www.petri.com -detail

    ResponseUri   : https://www.petri.com/
    ContentLength : -1
    ContentType   : text/html; charset=UTF-8
    LastModified  : 1/19/2015 12:14:57 PM
    Status        : 200
.Example
    PS C:\> get-content D:\temp\uris.txt | test-uri -Detail | where { $_.status -ne 200 -OR $_.contentType -notmatch "application"}

    ResponseUri   : http://files.snapfiles.com/localdl936/CrystalDiskInfo7_2_0.zip
    ContentLength : 23070
    ContentType   : text/html
    LastModified  : 1/19/2015 11:34:44 AM
    Status        : 200

    ResponseURI   : http://download.bleepingcomputer.com/grinler/rkill
    ContentLength :
    ContentType   :
    LastModified  :
    Status        : 404

    Test a list of URIs and filter for those that are not OK or where the type is not an application.
.Notes
    Last Updated: January 19, 2015
    Version     : 1.0

    https://www.petri.com/testing-uris-urls-powershell

.Link
    Invoke-WebRequest
#>

    [CmdletBinding(DefaultParameterSetName="Default")]
    Param(
        [Parameter(Position=0,Mandatory,HelpMessage="Enter the URI path starting with HTTP or HTTPS", ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidatePattern( "^(http|https)://" )]
        [Alias("url")]
        [string]$URI,

        [Parameter(ParameterSetName="Detail")]
        [Switch]$Detail,

        [ValidateScript({$_ -ge 0})]
        [int]$Timeout = 30
    )

    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"
        Write-Verbose -message "Using parameter set $($PSCmdlet.ParameterSetName)"
    }

    Process {
        Write-Verbose -Message "Testing $uri"
        Try {
            #hash table of parameter values for Invoke-Webrequest
            $paramHash = @{
                UseBasicParsing  = $True
                DisableKeepAlive = $True
                Uri              = $uri
                Method           = 'Head'
                ErrorAction      = 'stop'
                TimeoutSec       = $Timeout
            }
            $test = Invoke-WebRequest @paramHash

            if ($Detail) {
                $test.BaseResponse | Select ResponseURI,ContentLength,ContentType,LastModified, @{Name="Status";Expression={$Test.StatusCode}}
            } else {
                if ($test.statuscode -ne 200) {
                    #it is unlikely this code will ever run but just in case
                    Write-Verbose -Message "Failed to request $uri"
                    write-Verbose -message ($test | out-string)
                    $False
                }
            else { $True }
            }
        }
        Catch {
        #there was an exception getting the URI
            write-verbose -message $_.exception
            if ($Detail) {
                #most likely the resource is 404
                $objProp = [ordered]@{
                    ResponseURI   = $uri
                    ContentLength = $null
                    ContentType   = $null
                    LastModified  = $null
                    Status        = 404
                }
                #write a matching custom object to the pipeline
                New-Object -TypeName psobject -Property $objProp

            } else { $false }
        }
    }

    end { Write-Verbose -Message "Ending $($MyInvocation.Mycommand)" }
}
