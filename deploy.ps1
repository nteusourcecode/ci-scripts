Import-Module WebAdministration #Make sure you have this module installed on your computer
$AppPoolName = $env:APPPOOL_NAME
Write-Host ("ABC" + $env:APPPOOL_NAME)
#$AppPool = Get-Item IIS:\AppPools\$AppPoolName
#$AppPool.startMode = "alwaysrunning"
#$AppPool | Set-Item -Verbose
