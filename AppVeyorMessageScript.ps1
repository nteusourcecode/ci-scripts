$json = Get-Content 'C:\ciscripts\AppVeyorMessageTemplate.json'
[Environment]::SetEnvironmentVariable("MESSAGE_TEMPLATE", $json);