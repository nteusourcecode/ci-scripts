Import-Module WebAdministration #Make sure you have this module installed on your computer
$AppPoolName = $env:apppool_name
$AppPool = Get-Item IIS:\AppPools\$AppPoolName
$AppPool.startMode = "alwaysrunning"
$AppPool | Set-Item -Verbose
