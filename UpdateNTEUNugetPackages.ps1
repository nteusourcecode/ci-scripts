if(Test-Path $env:NTEU_PACKAGES_PATH)
{
	$xmlDoc = [xml](Get-Content $env:NTEU_PACKAGES_PATH);
	if($xmlDoc.NTEUPackages.HasChildNodes)
	{
		$xmlDoc.NTEUPackages |  ForEach-Object {
		Write-Host $_.Package
                nuget update $env:PROJECT_CSPROJ_PATH -FileConflictAction overwrite -Id $_.Package
	    	}
	}
}
