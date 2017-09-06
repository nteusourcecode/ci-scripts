if(Test-Path $env:NTEU_PACKAGES_PATH)
{
	$xmlDoc = [xml](Get-Content $env:NTEU_PACKAGES_PATH);
	if($xmlDoc.NTEUPackages.HasChildNodes)
	{
	    $xmlDoc.NTEUPackages.Package |  ForEach-Object {
	        Write-Host ("PackagesPath: " + "$($env:PACKAGES_PATH)$($_.id).$($_.version)\lib")
      		$framework = Get-ChildItem "$($env:PACKAGES_PATH)$($_.id).$($_.version)\lib" | Sort-Object Name -descending | Select-Object Name -First 1 
      		
		$xmlDocProjectConfig = [xml](Get-Content $env:PROJECT_PACKAGES_PATH);
		$nodeToUpdate = $xmlDocProjectConfig.packages.SelectSingleNode("package[@id='$($_.id)']")
      		$nodeToUpdate.SetAttribute("targetFramework", $framework.Name)
      		$xmlDocProjectConfig.Save($env:PROJECT_PACKAGES_PATH)
		
		$csProj = $env:PROJECT_CSPROJ_PATH
		$docCsproj = (Get-Content $csProj) -as [Xml]
		Write-Output ("version search:" + "$($_.id).$($_.version)")
		
		$projectToSetHintPath = $docCsproj.Project.ItemGroup.Reference | Where-Object {$_.HintPath -eq "$($_.id).$($_.version)" }
		Write-Output ("Hint Path:" + $projectToSetHintPath.HintPath)
		$projectToSetHintPath.HintPath = "$($env:PACKAGES_PATH)$($_.id).$($_.version)\lib\$($framework.Name)\$($_.id).dll"
		
      		Write-Output "Update package $($_.id) target framework to $($framework.Name)"
	    }
	}
}
