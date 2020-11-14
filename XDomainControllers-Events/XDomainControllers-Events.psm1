<#
Import-Module XDomainControllers-Events -force
###
gcm -Module XDomainControllers-Events
Get-Xhunt-Lockout | Export-Csv -Path C:\Temp\Lockoutevent.csv -NoTypeInformation
#>
Set-Location C:\projects
#Calling Function Get-XhuntNtlm
. .\XDomainControllers-Events\XDomainControllers-Events\public\Get-XhuntAES.ps1

#Calling Function Get-XhuntRC4
. .\XDomainControllers-Events\XDomainControllers-Events\public\Get-XhuntLockout.ps1

#Calling Function Get-Xhunt-AES
. .\XDomainControllers-Events\XDomainControllers-Events\public\Get-XhuntNtlm.ps1

#Calling Function Get-XhuntUptime
. .\XDomainControllers-Events\XDomainControllers-Events\public\Get-XhuntRC4.ps1

#Calling Function Get-XhuntLockout
. .\XDomainControllers-Events\XDomainControllers-Events\public\Get-XhuntUptime.ps1

#Calling Function Get-XhuntWUdate
. .\XDomainControllers-Events\XDomainControllers-Events\public\Get-XhuntWUdate.ps1
