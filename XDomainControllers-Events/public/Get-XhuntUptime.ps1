Function Get-XhuntUptime {
  $ErrorActionPreference = "Stop" 
  $computername = [system.directoryservices.activedirectory.domain]::GetCurrentDomain().DomainControllers.Name
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