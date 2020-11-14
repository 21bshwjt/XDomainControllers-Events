<#
Import-Module XDomainControllers-Events -force
###
gcm -Module XDomainControllers-Events
Get-Xhunt-Lockout | Export-Csv -Path C:\Temp\Lockoutevent.csv -NoTypeInformation
#>
Function Get-XhuntNtlm {
  $getadcs = (Get-ADGroupMember 'Domain Controllers').Name
  $ErrorActionPreference = "SilentlyContinue"
  Invoke-Command -ComputerName $getadcs -ScriptBlock {
    
    $query = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4624)]]</Select>
  </Query>
</QueryList>
"@
    $x = Get-WinEvent -FilterXml $query -ErrorAction SilentlyContinue | Select-Object -First 100
    $xmlString = $x.ToXml()
    foreach ($item in  $xmlString) {
      #Now get the Object by typecasting the XML String into XMLDocumentObject
      $xmlObject = [xml]$item
      $data = New-Object PSCustomObject
      $xmlObject.Event.EventData.data.ForEach( { $data | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.'#text' })
      $data   
    }
  } | Select-Object -Property @{Name = "DomainController"; Expression = { $_.PSComputerName } }, AuthenticationPackageName, TargetUserName, IpAddress | 
  Where-Object AuthenticationPackageName -EQ "ntlm"
}
Function Get-XhuntRC4 {
  $getadcs = (Get-ADGroupMember 'Domain Controllers').Name
  $ErrorActionPreference = "SilentlyContinue"
  Invoke-Command -ComputerName $getadcs -ScriptBlock {
    
    $query = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4769)]]</Select>
  </Query>
</QueryList>
"@
    $x = Get-WinEvent -FilterXml $query | Select-Object -First 100
    $xmlString = $x.ToXml()
    foreach ($item in  $xmlString) {
      #Now get the Object by typecasting the XML String into XMLDocumentObject
      $xmlObject = [xml]$item
      $data = New-Object PSCustomObject
      $xmlObject.Event.EventData.data.ForEach( { $data | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.'#text' })
      $data   
    }
  } | Select-Object -Property @{Name = "DomainController"; Expression = { $_.PSComputerName } }, TargetUserName, @{Name = "KerbType"; Expression = { $_.TicketEncryptionType } } , IpAddress, Status, TicketOptions | Where-Object KerbType -EQ "0x17"

}
Function Get-XhuntAES {
  $getadcs = (Get-ADGroupMember 'Domain Controllers').Name
  $ErrorActionPreference = "SilentlyContinue"
  Invoke-Command -ComputerName $getadcs -ScriptBlock {    
    $query = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4769)]]</Select>
  </Query>
</QueryList>
"@
    $x = Get-WinEvent -FilterXml $query | Select-Object -First 100
    $xmlString = $x.ToXml()
    foreach ($item in  $xmlString) {
      #Now get the Object by typecasting the XML String into XMLDocumentObject
      $xmlObject = [xml]$item
      $data = New-Object PSCustomObject
      $xmlObject.Event.EventData.data.ForEach( { $data | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.'#text' })
      $data   
    }
  } | Select-Object -Property @{Name = "DomainController"; Expression = { $_.PSComputerName } }, TargetUserName, @{Name = "KerbType"; Expression = { $_.TicketEncryptionType } } , IpAddress, Status, TicketOptions | Where-Object KerbType -EQ "0x12"

}

Function Get-XhuntUptime {
  $ErrorActionPreference = "Stop" 
  $computername = (Get-ADGroupMember 'Domain Controllers').Name
  # use DCOM for older systems that do not run with WinRM remoting
  $option = New-CimSessionOption -Protocol Wsman

  $Uptimeobj = foreach ($c in $computername) {
    Try {
      $session = New-CimSession -ComputerName $c -SessionOption $option

      $bootTime = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $session | Select-Object -ExpandProperty LastBootupTime
      $upTime = New-TimeSpan -Start $bootTime

      $min = [int]$upTime.TotalMinutes
      $ut = [math]::Round($($min / 60 / 24))

      [pscustomobject]@{
        DomainController = $c
        Uptime_Day       = $ut
      }
      Remove-CimSession -CimSession $session
    }
    Catch {     
      $ObjErr = [pscustomobject]@{
        DomainController = $c
        Uptime           = "Not Reachable"
      }
      $ObjErr  | Add-Content C:\temp\DCUptimeErr.txt -Verbose

    }
  }
  $Uptimeobj | Sort-Object Uptime_Day -Descending
  #Write-Host "Total $($Uptimeobj.count)"
}
Function Get-XhuntLockout {
  $getadcs = [system.directoryservices.activedirectory.domain]::GetCurrentDomain().DomainControllers.Name
  $ErrorActionPreference = "SilentlyContinue"
  Invoke-Command -ComputerName $getadcs -ScriptBlock {
    $query = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4625)]]</Select>
  </Query>
</QueryList>
"@
    $x = Get-WinEvent -FilterXml $query | Select-Object -First 100
    $xmlString = $x.ToXml()
    foreach ($item in  $xmlString) {
      #Now get the Object by typecasting the XML String into XMLDocumentObject
      $xmlObject = [xml]$item
      $data = New-Object PSCustomObject
      $xmlObject.Event.EventData.data.ForEach( { $data | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.'#text' })
      $data   
    }
  } | Select-Object -Property @{Name = "ADC"; Expression = { $_.PSComputerName } }, TargetUserName, IpAddress, Status, FailureReason, SubStatus, LogonType
} 

Function Get-XhuntWUdate {
  $getadcs = (Get-ADGroupMember 'Domain Controllers').Name
  $ErrorActionPreference = "SilentlyContinue"
  Invoke-Command -ComputerName $GetADCs -ScriptBlock { Get-HotFix | Select-Object -Last 1 } | 
  Select-Object -Property @{Name = "DomainController"; Expression = { $_.PSComputerName } }, InstalledBy, HotFixID, InstalledOn | Sort-Object InstalledOn
}
