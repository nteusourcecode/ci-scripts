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
		
   $hasDeployPowershell = $xml.Project.Target | Where-Object {$_.Name -eq 'BeforeBuild'} | Select-Object -Property {$_.ItemGroup.Content.Include}

	if(!($hasDeployPowershell.'$_.ItemGroup.Content.Include' -eq 'deploy.ps1'))
	{
		$target = $xml.CreateElement("Target", $xml.DocumentElement.NamespaceURI)
		$target.SetAttribute("Name", "BeforeBuild")
		$itemGroup = $xml.CreateElement("ItemGroup", $xml.DocumentElement.NamespaceURI)
		$content = $xml.CreateElement("Content", $xml.DocumentElement.NamespaceURI)
		$content.SetAttribute("Include", 'deploy.ps1')
		$itemGroup.AppendChild($content)
		$target.AppendChild($itemGroup)
		$xml.Project.AppendChild($target)

		$xml.Save($csProjPath)

		Write-Host "deploy.ps1 was added as a target to the .csproj file"
	}
}
