$packagesPath = $env:PACKAGES_PATH
$packagesConfig = $env:PROJECT_PACKAGES_PATH
$xmlDoc = [xml](Get-Content $packagesConfig);

$csProj = $env:PROJECT_CSPROJ_PATH
$docCsproj = (Get-Content $csProj) -as [Xml]

$packageNames = Get-ChildItem $packagesPath | Where-Object Name -NotMatch '^Microsoft.' | Select-Object Name
#Write-Output $packageNames

foreach($i in $packageNames)
{
	#Write-Output $i
	$currentLibPath = "$($packagesPath)\$($i.Name)\lib"
	$framework = ""

	if(Test-Path $currentLibPath)
	{
		$frameworkNode = Get-ChildItem $currentLibPath | Where-Object Name -Match '^net[0-9][0-9]' | Sort-Object Name -descending | Select-Object Name -First 1
		if($framework.Length -ge 1 -and !$framework.Name.StartsWith("net"))
		{
			$framework.Name = $frameworkNode.Name
		}
	}
	
	if([string]::IsNullOrEmpty($framework.Name) -or [string]::IsNullOrEmpty($framework))
	{
		$framework = "net45"
	}

	#Write-Output $i.Name.IndexOf(".")
	$indexStartOfVersion = $i.Name.IndexOf(".")
	$packageVersion = $i.Name.Substring($indexStartOfVersion + 1)
	$packageName = $i.Name.Substring(0, $indexStartOfVersion)

	#Write-Output $framework

	$addPackage = $xmlDoc.packages.SelectSingleNode("package[@id='$($packageName)']").Count -eq 0
	if($addPackage)
	{
		Write-Host "adding package $($packageName) to packages.config"
		$newPackageNode = $xmlDoc.CreateElement("package", $xmlDoc.DocumentElement.NamespaceURI)
		$newPackageNode.SetAttribute("id", $packageName)
		$newPackageNode.SetAttribute("version", $packageVersion)
		$newPackageNode.SetAttribute("targetFramework", $framework)
		$xmlDoc.packages.AppendChild($newPackageNode)
		$xmlDoc.Save($packagesConfig)
	}
	
	#Add package reference
 	$newcsItemGroup = $docCsproj.CreateElement("ItemGroup", $docCsproj.DocumentElement.NamespaceURI)
	$newcsReference = $docCsproj.CreateElement("Reference", $docCsproj.DocumentElement.NamespaceURI)
	$newcsReference.SetAttribute("Include", $packageName + ", Version=$($packageVersion), Culture=neutral, processorArchitecture=MSIL");
	$newcsHintPath = $docCsproj.CreateElement("HintPath", $docCsproj.DocumentElement.NamespaceURI)
	#$newcsHintPath.InnerXml = "$($packageName).$($packageVersion)"
	$newcsHintPath.InnerXml = $i.Name
	$newcsRefPrivate = $docCsproj.CreateElement("Private", $docCsproj.DocumentElement.NamespaceURI)
	$newcsRefPrivate.InnerXml = "True"

	$newcsReference.AppendChild($newcsHintPath)
	$newcsReference.AppendChild($newcsRefPrivate)
	$newcsItemGroup.AppendChild($newcsReference)
	$docCsproj.Project.AppendChild($newcsItemGroup)	
	$docCsproj.Save($csproj)	
}
