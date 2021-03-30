$json = Get-Content 'C:\ciscripts\AppVeyorMessageTemplate.json'
[Environment]::SetEnvironmentVariable("MESSAGE_TEMPLATE", $json);
Write-Host "MESSAGE_TEMPLATE: $($env:MESSAGE_TEMPLATE)"