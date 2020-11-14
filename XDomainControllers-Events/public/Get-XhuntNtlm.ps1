Function Get-XhuntNtlm {
  $getadcs = [system.directoryservices.activedirectory.domain]::GetCurrentDomain().DomainControllers.Name
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