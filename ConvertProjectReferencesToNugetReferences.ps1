function Convert-ProjectReferences-To-NugetReferences {
	$packagesConfig = 'C:\projects\hello-world-p1\helloworldp1\packages.config'
	$docPackagesConfig = (Get-Content $packagesConfig) -as [Xml]
	$newAppSetting = $docPackagesConfig.CreateElement("package")
	$docPackagesConfig.packages.AppendChild($newAppSetting)
	$newAppSetting.SetAttribute("id","hellosupportl1");
	$newAppSetting.SetAttribute("version","1.0.0");
	$newAppSetting.SetAttribute("targetFramework","net46");
	$docPackagesConfig.Save($packagesConfig)

	$csproj = 'C:\projects\hello-world-p1\helloworldp1\helloworldp1.csproj'
	$docCsproj = (Get-Content $csproj) -as [Xml]
	$csrefToRemove = $docCsproj.Project.ItemGroup.ProjectReference | Where-Object {$_.Name -eq "hellosupportl1" } | ForEach-Object {
		# Remove each node from its parent
		[void]$_.ParentNode.RemoveChild($_)
	}
	$docCsproj.Save($csproj)

	slnProj = 'C:\projects\hello-world-p1\helloworldp1.sln'
	$docSlnProj = (Get-Content $slnProj)
	$lineNumberToDelete = $docSlnProj |Select-String -Pattern "hellosupportl1" -CaseSensitive | Select-Object LineNumber
	$docSlnProj2 = $docSlnProj | Foreach {$n=1}{if (($n++) -ne ($lineNumberToDelete.LineNumber)) {$_}}
	$docSlnProj2 | Foreach {$n=1}{if (($n++) -ne ($lineNumberToDelete.LineNumber)) {$_}} | Set-Content -Path $slnProj
	}
