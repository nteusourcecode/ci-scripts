cd  $env:PROJECT_PATH
#Files to modify
$packagesConfig = $env:PROJECT_PACKAGES_PATH
if(!(Test-Path $packagesConfig))
{
	New-Item -path $packagesConfig -type "file" -Force
	Write-Host "Created new packages.config"
	$XML_Path = $packagesConfig
	$xmlWriter = New-Object System.XMl.XmlTextWriter($XML_Path,$Null)
	$xmlWriter.Formatting = 'Indented'
	$xmlWriter.Indentation = 1
	$XmlWriter.IndentChar = "`t"
	$xmlWriter.WriteStartDocument()
	$xmlWriter.WriteStartElement('packages')
	$xmlWriter.WriteEndElement()
	$xmlWriter.Flush()
	$xmlWriter.Close()
}
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
	#$currentPackageInAppveyorRepo = Find-Package $currentPackageToAdd
	#Write-Host ("Adding Package " + $currentPackageInAppveyorRepo.Name + " Version: " + $currentPackageInAppveyorRepo.Version)
	#nuget sources
        #$packageIdVer = (nuget list $currentPackageToAdd -source AppVeyorAccountFeed) -split " "
	#$currentPackageVersion = $packageIdVer[$packageIdVer.Count - 1]
	$packageIdVer = nuget list $currentPackageToAdd -source AppVeyorAccountFeed
	$currentPackageVersion = $packageIdVer -split '\r?\n' -clike "$($currentPackageToAdd) 1.0.*" -split " " | Select-Object -Last 1
	
	Write-Host ("packageIdVer: " +  $packageIdVer)
	Write-Host ("Adding Package " + $currentPackageToAdd + " Version: " + $currentPackageVersion)
	
	#BEGIN Add package to NTEU Package XML
	$nugetPackageNameNode = $xmlDoc.CreateElement("Package", $xmlDoc.DocumentElement.NamespaceURI)
	#$nugetPackageNameNode.InnerText = $currentPackageToAdd
	$nugetPackageNameNode.SetAttribute("id", $currentPackageToAdd)
	$nugetPackageNameNode.SetAttribute("version", $currentPackageVersion)
	$xmlDoc.SelectSingleNode("//NTEUPackages").AppendChild($nugetPackageNameNode)

	#BEGIN update packages.confg
	$newAppSetting = $docPackagesConfig.CreateElement("package", $docPackagesConfig.DocumentElement.NamespaceURI)
	$packagesNode = $docPackagesConfig.SelectSingleNode("packages")
	$packagesNode.AppendChild($newAppSetting)
	#$docPackagesConfig.packages.AppendChild($newAppSetting)
	$newAppSetting.SetAttribute("id", $currentPackageToAdd);
	$newAppSetting.SetAttribute("version", $currentPackageVersion);
	#$newAppSetting.SetAttribute("targetFramework","net45");
	$docPackagesConfig.Save($packagesConfig)
	#Get-Content $packagesConfig
	
	#BEGIN update .csproj
	$csrefToRemove = $docCsproj.Project.ItemGroup.ProjectReference | Where-Object {$_.Name -eq $currentPackageToAdd } | ForEach-Object {
		#Remove each node from its parent
		[void]$_.ParentNode.RemoveChild($_)
	}
	$docCsproj.Save($csproj)
	
	#Add package reference
	nuget install $currentPackageToAdd -OutputDirectory $env:PACKAGES_PATH
	$directoryToSearch = Resolve-Path $env:PACKAGES_PATH
	(Get-Childitem -Path $directoryToSearch -Recurse)
	Write-Host ("directoryToSearch: $($directoryToSearch)")
	ls $env:PACKAGES_PATH
	$assemblyPathFullName = (Get-Childitem -Path $directoryToSearch -Recurse -Filter '$($currentPackageToAdd).dll' | Select-Object FullName  -Last 1)
	Write-Host ("Assembly path for package $($currentPackageToAdd): $($assemblyPathFullName.FullName)")
	$Assembly = [Reflection.Assembly]::Loadfile($assemblyPathFullName.FullName)

	$AssemblyName = $Assembly.GetName()
	$Assemblyversion = $AssemblyName.version
 	$newcsItemGroup = $docCsproj.CreateElement("ItemGroup", $docCsproj.DocumentElement.NamespaceURI)
	$newcsReference = $docCsproj.CreateElement("Reference", $docCsproj.DocumentElement.NamespaceURI)
	#$newcsReference.SetAttribute("Include", $currentPackageToAdd + ", Version=" + $currentPackageVersion +", Culture=neutral, processorArchitecture=MSIL");
	$newcsReference.SetAttribute("Include", $currentPackageToAdd + ", Version=$($AssemblyVersion), Culture=neutral, processorArchitecture=MSIL");
	$newcsHintPath = $docCsproj.CreateElement("HintPath", $docCsproj.DocumentElement.NamespaceURI)
	$newcsHintPath.InnerXml = "$($currentPackageToAdd).$($currentPackageVersion)"
	$newcsRefPrivate = $docCsproj.CreateElement("Private", $docCsproj.DocumentElement.NamespaceURI)
	$newcsRefPrivate.InnerXml = "True"

	$newcsReference.AppendChild($newcsHintPath)
	$newcsReference.AppendChild($newcsRefPrivate)
	$newcsItemGroup.AppendChild($newcsReference)
	$docCsproj.Project.AppendChild($newcsItemGroup)	
	$docCsproj.Save($csproj)	
	#nuget install $currentPackageToAdd -OutputDirectory $env:PACKAGES_PATH
	#Get-Content $csproj
	
	#BEGIN update .sln
	$lineNumberToDelete = $docSlnProj |Select-String -Pattern $currentPackageToAdd -CaseSensitive | Select-Object LineNumber
	$docSlnProj2 = $docSlnProj | Foreach {$n=1}{if (($n++) -ne ($lineNumberToDelete.LineNumber)) {$_}}
	$docSlnProj2 | Foreach {$n=1}{if (($n++) -ne ($lineNumberToDelete.LineNumber)) {$_}} | Set-Content -Path $slnProj
}

 $xmlDoc.Save($XML_Path)
