[string]$nuspecPath = $env:PROJECT_PATH
[string]$projectName = $env:PROJECT_NAME
[string]$buildVersion = $env:APPVEYOR_BUILD_VERSION

if(!(Test-Path $env:PROJECT_NUSPEC_PATH))
{
	nuget spec ($env:PROJECT_PATH + "\" + $env:PROJECT_NAME)
}

$xmlPath = $env:PROJECT_NUSPEC_PATH
$xml = [xml](get-content $xmlPath)
$xml.package.metadata.id = $projectName
$xml.package.metadata.version = $buildVersion
$xml.package.metadata.authors = "NTEU Developer Team"
$xml.package.metadata.owners = "NTEU"
$xml.package.metadata.description = "Automatic Package Build For Referenced Projects"

$nodes = $xml.package.ChildNodes
$nodes | % {
	$child_node = $_.SelectSingleNode('licenseUrl')
	if($child_node)
	{
		$_.RemoveChild($child_node) | Out-Null
	}
	$child_node = $_.SelectSingleNode('projectUrl')
	if($child_node)
	{
		$_.RemoveChild($child_node) | Out-Null
	}
	$child_node = $_.SelectSingleNode('iconUrl')
	if($child_node)
	{
		$_.RemoveChild($child_node) | Out-Null
	}
	$child_node = $_.SelectSingleNode('requireLicenseAcceptance')
	if($child_node)
	{
		$_.RemoveChild($child_node) | Out-Null
	}
	$child_node = $_.SelectSingleNode('releaseNotes')
	if($child_node)
	{
		$_.RemoveChild($child_node) | Out-Null
	}
	$child_node = $_.SelectSingleNode('copyright')
	if($child_node)
	{
		$_.RemoveChild($child_node) | Out-Null
	}
	$child_node = $_.SelectSingleNode('tags')
	if($child_node)
	{
		$_.RemoveChild($child_node) | Out-Null
	}
	$child_node = $_.SelectSingleNode('dependencies')
	if($child_node)
	{
		$_.RemoveChild($child_node) | Out-Null
	}
}

Write-Host ($projectName +".nuspec has been updated.")
Write-Host ($projectName +".nuspec version: " + $buildVersion)

$xml.Save($xmlPath)
