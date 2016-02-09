sal e exit
sal q exit
sal import Import-Module
sal remove Remove-Module

#Remove problematic default aliases
rm alias:curl, alias:wget -ea 0
