$packagePath = $env:PROJECT_PACKAGES_PATH
$nugetSpecPath = $env:PROJECT_NUSPEC_PATH

if(Test-Path $packagePath)
{
	if(Test-Path $nugetSpecPath)
	{
		$packageDoc = (Get-Content $packagePath) -as [Xml]
		if($packageDoc.packages.HasChildNodes)
		{			
			$nugetSpecDoc = ( Select-Xml -Path $nugetSpecPath -XPath / ).Node
			Write-Output $nugetSpecDoc
			$dependencies = $nugetSpecDoc.CreateElement("dependencies", $nugetSpecDoc.DocumentElement.NamespaceURI)
			$packageDoc.packages.package |  ForEach-Object {
				Write-Host $_.id
				$dependencyToAdd = $nugetSpecDoc.CreateElement("dependency", $nugetSpecDoc.DocumentElement.NamespaceURI)
				$dependencyToAdd.SetAttribute("id",$_.id)
				$dependencyToAdd.SetAttribute("version",$_.version)
				$dependencies.AppendChild($dependencyToAdd)
			}
			$nugetSpecDoc.package.metadata.AppendChild($dependencies)
			$nugetSpecDoc.Save($nugetSpecPath)
		}
	}
}
