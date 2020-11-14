Function Get-XhuntWUdate {
  $getadcs = [system.directoryservices.activedirectory.domain]::GetCurrentDomain().DomainControllers.Name
  $ErrorActionPreference = "SilentlyContinue"
  Invoke-Command -ComputerName $GetADCs -ScriptBlock { Get-HotFix | Select-Object -Last 1 } | 
  Select-Object -Property @{Name = "DomainController"; Expression = { $_.PSComputerName } }, InstalledBy, HotFixID, InstalledOn | Sort-Object InstalledOn
}
