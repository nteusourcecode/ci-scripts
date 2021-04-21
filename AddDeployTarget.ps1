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

# Create build info file
$buildInfoPath = "$($env:PROJECT_PATH)\NteuAppBuild.txt"
New-Item -path $buildInfoPath -type "file" -Force -Value "APPPOOL_NAME=$env:APPPOOL_NAME\nBUILD_DATE=$env:APPVEYOR_REPO_COMMIT_TIMESTAMP\nBUILD_VERSION=$env:APPVEYOR_BUILD_VERSION"
Write-Host Resolve-Path $buildInfoPath
Write-Host "Build info file created"