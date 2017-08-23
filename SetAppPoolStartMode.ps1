Import-Module WebAdministration #Make sure you have this module installed on your computer
$AppPoolName = $env:apppool_name
Write-Host IIS:\AppPools\$AppPoolName
#$AppPool = Get-Item IIS:\AppPools\$AppPoolName
#$AppPool.startMode = "alwaysrunning"
#$AppPool | Set-Item -Verbose
