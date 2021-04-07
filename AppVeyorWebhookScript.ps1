param(
    [String] $projectName,
    [String] $buildVersion,
    [String] $buildUrl,
    [String] $branch,
    [String] $commitAuthor,
    [String] $commitId,
    [String] $commitMessage,
    [String] $duration,
    [String] $repositoryName,
    [String] $repositoryProvider,
    [String] $status,
    [String] $started,
    [String] $finished,
    [String] $passed,
    [String] $failed
)
$buildStatus = if ($passed) {"passed"} elseif ($failed) {"failed"}
$themeColor = if ($passed) {"00FF00"} elseif ($failed) {"FF0000"}
$payload  = @{
    "title"= "AppVeyor Build $($buildStatus)"
    "summary"= "Build $($projectName) $($buildVersion) $($status)"
    "themeColor"= "$($themeColor)"
    "sections"=
        @{
            "activityTitle"= "$($commitAuthor) on $($commitDate) ( $($repositoryProvider)/$($repositoryName) )"
            "activityText"= "[Build $($projectName) $($buildVersion) $($status)]($($buildUrl))"
        },
        @{
            "title"= "Details"
            "facts"=
                @{
                    "name"= "Commit"
                    "value"= "[$($commitId) by $($commitAuthor) on $($branch) at $($commitDate)]($($commitUrl))"
                },
                @{
                    "name"= "Message"
                    "value"= "$($commitMessage)"
                },
                @{
                    "name"= "Duration"
                    "value"= "$($duration) ($($started) - $($finished))"
                }
        }
}
Write-Host (ConvertTo-Json -Compress -InputObject $payload -Depth 4)
Invoke-WebRequest `
	-Body (ConvertTo-Json -Compress -InputObject $payload -Depth 4) `
	-Method Post `
    -Uri "https://outlook.office.com/webhook/028e3fd9-f85e-4bd1-bf59-85e84f1cad30@23c51c51-37f5-4067-9cc3-2259cef9fcef/IncomingWebhook/1177a813026d4695bada53af5b6b0111/722cc6c1-82f6-49da-bcda-03d4770dfd56"
