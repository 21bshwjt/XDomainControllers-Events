## Hunt Weaker Cipher & Weaker Authentication Protocols using PowerShell
```diff
+ Get Lockout ,NTLM , RC4, AES , Domain Controllers Uptime & Last Patching Date.
+ The code is designed to work with WinRM and requires the Active Directory (AD) module.
```

### Use-case
Get Weaker Cipher (RC4) & Weaker Authentication Protocol (NTLM) events from Domain Controllers.  

### Note
The script runs on Domain Controllers & Domain Admin privilege is needed to run that. 

### Instructions
```powershell
C:\> Install-Module -Name XDomainControllers-Events -RequiredVersion 1.3 -Force -Verbose -Repository PSGallery
C:\> Import-Module XDomainControllers-Events -Verbose
C:\> Get-Command -Module XDomainControllers-Events

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Get-XhuntAES                                       1.3        XDomainControllers-Events
Function        Get-XhuntLockout                                   1.3        XDomainControllers-Events
Function        Get-XhuntNtlm                                      1.3        XDomainControllers-Events
Function        Get-XhuntRC4                                       1.3        XDomainControllers-Events
Function        Get-XhuntUptime                                    1.3        XDomainControllers-Events
Function        Get-XhuntWUdate                                    1.3        XDomainControllers-Events
```




