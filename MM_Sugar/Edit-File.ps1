<#

.SYNOPSIS
    Edit multiple files in $Env:EDITOR

.EXAMPLE
    PS> dir ..\*.txt | ed  .\my_file.txt

    Edit all text files from the parent directory along with my_file.txt from current dir.
#>
function Edit-File () { $f = $input + $args | gi | % { $_.fullname };  iex "$Env:EDITOR $f" }

sal ed Edit-File
sal edit Edit-File
