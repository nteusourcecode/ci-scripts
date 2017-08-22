[string]$nuspecPath = $env:PROJECT_PATH
[string]$projectName = $env:PROJECT_NAME
[string]$buildVersion = $env:APPVEYOR_BUILD_VERSION

$xmlPath = ($nuspecPath + "\" + $projectName + ".nuspec")
$xml = [xml](get-content $xmlPath)
$xml.package.metadata.id = $projectName
$xml.package.metadata.version = $buildVersion
$xml.package.metadata.authors = "NTEU Developer Team"
$xml.package.metadata.owners = "NTEU"


Write-Host ($projectName +".nuspec has been updated.")
Write-Host ($projectName +".nuspec version: " + $buildVersion)

$xml.Save($xmlPath)
