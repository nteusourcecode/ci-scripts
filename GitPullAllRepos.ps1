$dirs = Get-ChildItem -Path ../ | Where-Object {$_.PSIsContainer -eq $True}
$back = pwd
foreach ($dir in $dirs)
{
    cd $dir.FullName
    Write-Host $dir.FullName
	git pull --all
}   
cd $back.Path
