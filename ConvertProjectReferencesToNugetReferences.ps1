param (
    [string]$projpath = $null,
    [string]$projname = $null
)

#Files to modify
$packagesConfig = $projpath + '\' + $projname +'\packages.config'
$docPackagesConfig = (Get-Content $packagesConfig) -as [Xml]

$csProj = $projpath + '\' + $projname +'\' + $projname + '.csproj'
$docCsproj = (Get-Content $csProj) -as [Xml]

$slnProj = $projpath + '\' + $projname + '.sln'
$docSlnProj = (Get-Content $slnProj)

[System.Collections.ArrayList]$NugetPackagesToAdd = New-Object System.Collections.ArrayList

#Find Project References
$nugetprojToAdd = $docCsproj.Project.ItemGroup.ProjectReference | ForEach-Object {
	if (-not ([string]::IsNullOrEmpty($_.Name)))
	{
		$NugetPackagesToAdd.Add($_.Name)
	}
}

Write-Host ("References found: " + $NugetPackagesToAdd)

#Remove Existing References from the list of references to add
$nugetprojToRemove = $docPackagesConfig.packages.package | ForEach-Object {
	if (-not ([string]::IsNullOrEmpty($_.id)))
	{
		$NugetPackagesToAdd.Remove($_.id)
	}
}

Write-Host ("Packages to add: " + $NugetPackagesToAdd)

$NugetPackagesToAdd | ForEach-Object {
	$currentPackageToAdd = $_

	#BEGIN update packages.confg
	$newAppSetting = $docPackagesConfig.CreateElement("package", $docPackagesConfig.DocumentElement.NamespaceURI)
	$docPackagesConfig.packages.AppendChild($newAppSetting)
	$newAppSetting.SetAttribute("id", $currentPackageToAdd);
	$newAppSetting.SetAttribute("version","1.0.0");
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
