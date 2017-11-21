$csProjPath = $env:PROJECT_PATH

[System.Collections.ArrayList]$ReferencesFound = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$AppVeyorPackageName = New-Object System.Collections.ArrayList

$ReferencesFound.AddRange((dotnet list $csProjPath reference | select-object -skip 2))

$AppVeyorPackageName.AddRange((nuget list -source AppVeyorAccountFeed | select-object -skip 1 | ForEach-Object -Process {([String] $_).Split(" ")[0]}))

$ReferencesFound | ForEach-Object {
	if($AppVeyorPackageName -icontains [System.IO.Path]::GetFileNameWithoutExtension($_))
	{
		dotnet remove $csProjPath reference $_
		dotnet add $csProjPath package ([System.IO.Path]::GetFileNameWithoutExtension($_)) -s AppVeyorAccountFeed -n
		Write-Output "Replaced .csproj reference with appveyor nuget package: $($([System.IO.Path]::GetFileNameWithoutExtension($_)))"		
	}
	else
	{
		Write-Output "Appveyor nuget package not found expecting .csproj reference: $($_)"
	}
}
