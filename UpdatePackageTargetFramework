if(Test-Path $env:NTEU_PACKAGES_PATH)
{
	$xmlDoc = [xml](Get-Content $env:NTEU_PACKAGES_PATH);
	if($xmlDoc.NTEUPackages.HasChildNodes)
	{
		$xmlDoc.NTEUPackages.Package |  ForEach-Object {
      $framework = Get-ChildItem $env:PACKAGES_PATH + $_.id + "." + $_.version +"\lib" | Sort-Object Name -descending | Select-Object Name -First 1
      $nodeToUpdate = $xmlDoc.packages.SelectSingleNode("package[@id='$($framework.Name)']")
      $nodeToUpdate.SetAttribute("targetFramework", $framework.Name)
      $xmlDoc.Save($XML_Path)
      Write-Host "Set package $($_.id) target framework to $($framework.Name)"
	  }
	}
}
