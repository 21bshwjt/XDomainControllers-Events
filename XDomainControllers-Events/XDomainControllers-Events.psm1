<#
Import-Module XDomainControllers-Events -force
###
gcm -Module XDomainControllers-Events
Get-Xhunt-Lockout | Export-Csv -Path C:\Temp\Lockoutevent.csv -NoTypeInformation
#>
Set-Location C:\
#Calling Function Get-XhuntNtlm
. .\Windows\System32\WindowsPowerShell\v1.0\Modules\XDomainControllers-Events\public\Get-XhuntNtlm.ps1

#Calling Function Get-XhuntRC4
. .\Windows\System32\WindowsPowerShell\v1.0\Modules\XDomainControllers-Events\public\Get-XhuntRC4.ps1

#Calling Function Get-Xhunt-AES
. .\Windows\System32\WindowsPowerShell\v1.0\Modules\XDomainControllers-Events\public\Get-XhuntAES.ps1

#Calling Function Get-XhuntUptime
. .\Windows\System32\WindowsPowerShell\v1.0\Modules\XDomainControllers-Events\public\Get-XhuntUptime.ps1

#Calling Function Get-XhuntLockout
. .\Windows\System32\WindowsPowerShell\v1.0\Modules\XDomainControllers-Events\public\Get-XhuntLockout.ps1

#Calling Function Get-XhuntWUdate
. .\Windows\System32\WindowsPowerShell\v1.0\Modules\XDomainControllers-Events\public\Get-XhuntWUdate.ps1
