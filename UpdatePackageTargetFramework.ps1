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
		
      		Write-Output "Update package $($_.id) target framework to $($framework.Name)"
	    }
	}
	
	if($xmlDoc.NTEUPackages.HasChildNodes)
	{
	    $xmlDoc.NTEUPackages.Package |  ForEach-Object {
	        Write-Host ("cs proj PackagesPath: " + "$($env:PACKAGES_PATH)$($_.id).$($_.version)\lib")
      		$framework = Get-ChildItem "$($env:PACKAGES_PATH)$($_.id).$($_.version)\lib" | Sort-Object Name -descending | Select-Object Name -First 1
      				
		$csProj = $env:PROJECT_CSPROJ_PATH
		$docCsproj = (Get-Content $csProj) -as [Xml]
		Get-Content $csProj
		#Write-Output 'ItemGroup:'
		#Write-Output $docCsproj.Project.ItemGroup
		#Write-Output 'Reference:'
		#Write-Output $docCsproj.Project.ItemGroup.Reference
		#Write-Output ("docCsproj.Project.ItemGroup.Reference.HintPath: for" + "$($_.id).$($_.version)":)
		Write-Output $docCsproj.Project.ItemGroup.Reference.HintPath		
		$projectToSetHintPath = $docCsproj.Project.ItemGroup.Reference | Where-Object {$_.HintPath -eq "$($_.id).$($_.version)" }		
		Write-Output $projectToSetHintPath
		$projectToSetHintPath.HintPath = "$($env:PACKAGES_PATH)$($_.id).$($_.version)\lib\$($framework.Name)\$($_.id).dll"
		$docCsproj.Save($csProj)
		
      		Write-Output "Update package $($_.id) target framework to $($framework.Name)"
	    }
	}
}
