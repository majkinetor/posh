sal remove  Remove-Module
sal import  Import-Module
sal new     New-Object

#Remove problematic default aliases
rm -ea 0 `
    alias:curl,
    alias:wget
