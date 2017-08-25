#Files to modify
$packagesConfig = $env:PROJECT_PACKAGES_PATH
$docPackagesConfig = (Get-Content $packagesConfig) -as [Xml]

$csProj = $env:PROJECT_CSPROJ_PATH
$docCsproj = (Get-Content $csProj) -as [Xml]

$slnProj = $env:PROJECT_SLN_PATH
$docSlnProj = (Get-Content $slnProj)

[System.Collections.ArrayList]$NugetPackagesToAdd = New-Object System.Collections.ArrayList

#Find Project References
$nugetprojToAdd = $docCsproj.Project.ItemGroup.ProjectReference | ForEach-Object {
	if (-not ([string]::IsNullOrWhiteSpace($_.Name)))
	{
		$NugetPackagesToAdd.Add($_.Name)
	}
}

Write-Host ("References found: " + $NugetPackagesToAdd)

#Remove Existing References from the list of references to add
$docPackagesConfig.packages.package | ForEach-Object {
	if (-not ([string]::IsNullOrWhiteSpace($_.id)))
	{
		$NugetPackagesToAdd.Remove($_.id)
	}
}

Write-Host ("Packages to add: " + $NugetPackagesToAdd)

#Create NTEU Package XML
New-Item -path $env:NTEU_PACKAGES_PATH -type "file" -Force
Write-Host "Created new file NTEU Package XML"
$XML_Path = $env:NTEU_PACKAGES_PATH
$xmlWriter = New-Object System.XMl.XmlTextWriter($XML_Path,$Null)
$xmlWriter.Formatting = 'Indented'
$xmlWriter.Indentation = 1
$XmlWriter.IndentChar = "`t"
$xmlWriter.WriteStartDocument()
$xmlWriter.WriteComment('These are the references that were converted into nuget packages.')
$xmlWriter.WriteStartElement('NTEUPackages')
$xmlWriter.WriteEndElement()
$xmlWriter.Flush()
$xmlWriter.Close()

$xmlDoc = [xml](Get-Content $XML_Path);

$NugetPackagesToAdd | ForEach-Object {
	$currentPackageToAdd = $_
	$currentPackageInAppveyorRepo = Find-Package $currentPackageToAdd
	Write-Host ("Adding Package " + $currentPackageInAppveyorRepo.Name + " Version: " + $currentPackageInAppveyorRepo.Version)

	#BEGIN Add package to NTEU Package XML
	$nugetPackageNameNode = $xmlDoc.CreateElement("Package", $xmlDoc.DocumentElement.NamespaceURI)
	$nugetPackageNameNode.InnerText = $currentPackageToAdd
	$xmlDoc.SelectSingleNode("//NTEUPackages").AppendChild($nugetPackageNameNode)

	#BEGIN update packages.confg
	$newAppSetting = $docPackagesConfig.CreateElement("package", $docPackagesConfig.DocumentElement.NamespaceURI)
	$packagesNode = $docPackagesConfig.SelectSingleNode("packages")
	$packagesNode.AppendChild($newAppSetting)
	#$docPackagesConfig.packages.AppendChild($newAppSetting)
	$newAppSetting.SetAttribute("id", $currentPackageToAdd);
	#$newAppSetting.SetAttribute("version", $currentPackageInAppveyorRepo.Version);
	#$newAppSetting.SetAttribute("version","1.0.0");
	$newAppSetting.SetAttribute("version","1.*");
	$newAppSetting.SetAttribute("targetFramework","net46");
	$docPackagesConfig.Save($packagesConfig)
	
	#BEGIN update .csproj
	$csrefToRemove = $docCsproj.Project.ItemGroup.ProjectReference | Where-Object {$_.Name -eq $currentPackageToAdd } | ForEach-Object {
		# Remove each node from its parent
		[void]$_.ParentNode.RemoveChild($_)
	}
	
	#Add package reference
	$newcsItemGroup = $docCsproj.CreateElement("ItemGroup", $docCsproj.DocumentElement.NamespaceURI)
	$newcsReference = $docCsproj.CreateElement("Reference", $docCsproj.DocumentElement.NamespaceURI)
	$newcsReference.SetAttribute("Include", $currentPackageToAdd + ", Version=1.0.0.0, Culture=neutral, processorArchitecture=MSIL");
	$newcsHintPath = $docCsproj.CreateElement("HintPath", $docCsproj.DocumentElement.NamespaceURI)
	$newcsHintPath.InnerXml = "..\packages\" + $currentPackageToAdd + ".1.0.0\lib\net46\" + $currentPackageToAdd + ".dll"
	$newcsRefPrivate = $docCsproj.CreateElement("Private", $docCsproj.DocumentElement.NamespaceURI)
	$newcsRefPrivate.InnerXml = "True"

	$newcsReference.AppendChild($newcsHintPath)
	$newcsReference.AppendChild($newcsRefPrivate)
	$newcsItemGroup.AppendChild($newcsReference)
	$docCsproj.Project.AppendChild($newcsItemGroup)	
	
	$docCsproj.Save($csproj)
	
	#BEGIN update .sln
	$lineNumberToDelete = $docSlnProj |Select-String -Pattern $currentPackageToAdd -CaseSensitive | Select-Object LineNumber
	$docSlnProj2 = $docSlnProj | Foreach {$n=1}{if (($n++) -ne ($lineNumberToDelete.LineNumber)) {$_}}
	$docSlnProj2 | Foreach {$n=1}{if (($n++) -ne ($lineNumberToDelete.LineNumber)) {$_}} | Set-Content -Path $slnProj
}

 $xmlDoc.Save($XML_Path)
