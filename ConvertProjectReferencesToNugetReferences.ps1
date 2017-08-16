function Convert-ProjectReferences-To-NugetReferences ($projpath, $projname) {
	$packagesConfig = $projpath + '\' + $projname +'\packages.config'
	$docPackagesConfig = (Get-Content $packagesConfig) -as [Xml]
	$newAppSetting = $docPackagesConfig.CreateElement("package")
	$docPackagesConfig.packages.AppendChild($newAppSetting)
	$newAppSetting.SetAttribute("id","hellosupportl1");
	$newAppSetting.SetAttribute("version","1.0.0");
	$newAppSetting.SetAttribute("targetFramework","net46");
	$docPackagesConfig.Save($packagesConfig)
	Write-Host $packagesConfig
	Write-Host $docPackagesConfig
	
	$csproj =  $projpath + '\' + $projname + '\' +$projname + '.csproj'
	$docCsproj = (Get-Content $csproj) -as [Xml]
	$csrefToRemove = $docCsproj.Project.ItemGroup.ProjectReference | Where-Object {$_.Name -eq "hellosupportl1" } | ForEach-Object {
		# Remove each node from its parent
		[void]$_.ParentNode.RemoveChild($_)
	}
	
	$newcsItemGroup = $docCsproj.CreateElement("ItemGroup", $docCsproj.DocumentElement.NamespaceURI)
	$newcsReference = $docCsproj.CreateElement("Reference", $docCsproj.DocumentElement.NamespaceURI)
	$newcsReference.SetAttribute("Include","hellosupportl1, Version=1.0.0.0, Culture=neutral, processorArchitecture=MSIL");
	$newcsHintPath = $docCsproj.CreateElement("HintPath", $docCsproj.DocumentElement.NamespaceURI)
	$newcsHintPath.InnerXml = "..\packages\hellosupportl1.1.0.0\lib\net46\hellosupportl1.dll"
	$newcsRefPrivate = $docCsproj.CreateElement("Private", $docCsproj.DocumentElement.NamespaceURI)
	$newcsRefPrivate.InnerXml = "True"

	$newcsReference.AppendChild($newcsHintPath)
	$newcsReference.AppendChild($newcsRefPrivate)
	$newcsItemGroup.AppendChild($newcsReference)
	$docCsproj.Project.AppendChild($newcsItemGroup)	
	
	$docCsproj.Save($csproj)
	
	$slnProj = $projpath + '\' + $projname + '.sln'
	$docSlnProj = (Get-Content $slnProj)
	$lineNumberToDelete = $docSlnProj |Select-String -Pattern "hellosupportl1" -CaseSensitive | Select-Object LineNumber
	$docSlnProj2 = $docSlnProj | Foreach {$n=1}{if (($n++) -ne ($lineNumberToDelete.LineNumber)) {$_}}
	$docSlnProj2 | Foreach {$n=1}{if (($n++) -ne ($lineNumberToDelete.LineNumber)) {$_}} | Set-Content -Path $slnProj
}
