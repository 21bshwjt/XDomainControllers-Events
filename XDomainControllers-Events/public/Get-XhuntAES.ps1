Function Get-XhuntAES {
  $getadcs = [system.directoryservices.activedirectory.domain]::GetCurrentDomain().DomainControllers.Name
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