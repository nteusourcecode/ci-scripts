if(Test-Path $env:NTEU_PACKAGES_PATH)
{
	$xmlDoc = [xml](Get-Content $env:NTEU_PACKAGES_PATH);
	if($xmlDoc.NTEUPackages.HasChildNodes)
	{
	    $xmlDoc.NTEUPackages.Package |  ForEach-Object {
	        Write-Host ("PackagesPath: " + "$($env:PACKAGES_PATH)$($_.id).$($_.version)\lib")
		ls
      		$framework = Get-ChildItem "$($env:PACKAGES_PATH)$($_.id).$($_.version)\lib" | Sort-Object Name -descending | Select-Object Name -First 1 
      		
		$xmlDocProjectConfig = [xml](Get-Content $env:PROJECT_PACKAGES_PATH);
		$nodeToUpdate = $xmlDocProjectConfig.packages.SelectSingleNode("package[@id='$($_.id)']")
      		$nodeToUpdate.SetAttribute("targetFramework", $framework.Name)
      		$xmlDocProjectConfig.Save($env:PROJECT_PACKAGES_PATH)
		
		$csProj = $env:PROJECT_CSPROJ_PATH
		$docCsproj = (Get-Content $csProj) -as [Xml]
		#Get-Content $csProj
		#Write-Host ("version search: " + "$($_.id).$($_.version)")
		$HintToken = "$($_.id).$($_.version)"
		#Write-Host ("Hint Token: " + $HintToken)
		#$projectToSetHintPath = $docCsproj.Project.ItemGroup.Reference | Where-Object {$_.HintPath -eq "$($_.id).$($_.version)" }
		$projectToSetHintPath = $docCsproj.Project.ItemGroup.Reference | Where-Object {$_.HintPath -eq $HintToken }
		#Write-Host ("Hint Path:" + $projectToSetHintPath.HintPath)
		#Write-Output $projectToSetHintPath.FirstChild.InnerText
		#Write-Host $projectToSetHintPath
		#Write-Host $docCsproj.Project.ItemGroup.Reference
		$projectToSetHintPath.HintPath = "$($env:PACKAGES_PATH)$($_.id).$($_.version)\lib\$($framework.Name)\$($_.id).dll"
		$docCsproj.Save($csProj)
		Get-Content $csProj
      		Write-Host "Update package $($_.id) target framework to $($framework.Name)"
	    }
	}
}
