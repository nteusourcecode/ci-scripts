$csProjPath = $env:PROJECT_PATH

[System.Collections.ArrayList]$ReferencesFound = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$AppVeyorPackageName = New-Object System.Collections.ArrayList

Write-Output (-not ([string]::IsNullOrEmpty(dotnet list $csProjPath reference))) 

$ReferencesFound.AddRange((dotnet list $csProjPath reference | select-object -skip 2))

$AppVeyorPackageName.AddRange((nuget list -source AppVeyorAccountFeed | select-object -skip 1 | ForEach-Object -Process {([String] $_).Split(" ")[0]}))

$ReferencesFound | ForEach-Object {
	$CurrentReference = $_
	if($AppVeyorPackageName -icontains [System.IO.Path]::GetFileNameWithoutExtension($CurrentReference))
	{
		dotnet remove $csProjPath reference $CurrentReference
		dotnet add $csProjPath package ([System.IO.Path]::GetFileNameWithoutExtension($CurrentReference)) -s AppVeyorAccountFeed -n
		Write-Output "Replaced .csproj reference with appveyor nuget package: $($([System.IO.Path]::GetFileNameWithoutExtension($CurrentReference)))"		
	}
	else
	{
		Write-Output "Appveyor nuget package not found expecting .csproj reference: $($CurrentReference)"
	}
}
