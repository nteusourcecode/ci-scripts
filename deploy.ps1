#Set app pool to always running
Import-Module WebAdministration 
$AppPoolName = $env:APPPOOL_NAME
$AppPool = Get-Item IIS:\AppPools\$AppPoolName
$AppPool.startMode = "alwaysrunning"
$AppPool | Set-Item -Verbose
