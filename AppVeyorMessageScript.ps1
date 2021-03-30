$json = Get-Content 'C:\ciscripts\AppVeyorMessageTemplate.json'
Write-Host $json
[Environment]::SetEnvironmentVariable("MESSAGE_TEMPLATE", $json);