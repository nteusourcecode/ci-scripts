$csProjPath = $env:PROJECT_CSPROJ_PATH
$deployps1Path = $env:PROJECT_DEPLOY_PATH

if(!(Test-Path $deployps1Path))
{
	Copy-Item C:\ciscripts\deploy.ps1 $env:PROJECT_PATH
}

if(Test-Path $deployps1Path)
{
	# load it into an XML object:
  $xml = New-Object -TypeName XML
  $xml.Load($csProjPath)

  $hasDeployPowershell = $xml.Project.ItemGroup | Where-Object {$_.Content.Include -eq 'deploy.ps1'}  | Select-Object -Property {$_.Content.Include} 

  if(!($hasDeployPowershell.'$_.Content.Include' -eq 'deploy.ps1'))
  {
    $newItemGroup = $xml.CreateElement("ItemGroup", $xml.DocumentElement.NamespaceURI)
    $newContent = $xml.CreateElement("Content", $xml.DocumentElement.NamespaceURI)
    $newContent.SetAttribute("Include", 'deploy.ps1')
    $newContent.SetAttribute("CopyToOutputDirectory", 'Always')
    $newItemGroup.AppendChild($newContent)
    $xml.Project.AppendChild($newItemGroup)

    $xml.Save($csProjPath)

    Write-Host "deploy.ps1 was added as a target to the .csproj file"
  }
  else
  {
    Write-Host "deploy.ps1 already exists in .csproj file"
  }
}
