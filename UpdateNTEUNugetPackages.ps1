if(Test-Path $env:NTEU_PACKAGES_PATH)
{
	$xmlDoc = [xml](Get-Content $env:NTEU_PACKAGES_PATH);
	if($xmlDoc.NTEUPackages.HasChildNodes)
	{
		$xmlDoc.NTEUPackages |  ForEach-Object {
       nuget update C:\projects\hello-world-p1\helloworldp1\helloworldp1.csproj -FileConflictAction overwrite -Id $_.Package
		}
	}
}
