param (
    [string]$IssueTitle,
    [string]$IssueBody
)

# Extract Area and Parent
if ($IssueBody -match 'Area:\s*([^\s]+)') {
    $area = $matches[1]
}
else {
    $area = ""
}
if ($IssueBody -match 'Parent:\s*(\d+)') {
    $parent = $matches[1]
}
else {
    $parent = ""
}

# Remove Area and Parent from description
$cleanedDescription = $IssueBody -replace 'Area:\s*[^\s]+', ''
$cleanedDescription = $cleanedDescription -replace 'Parent:\s*\d+', ''
$cleanedDescription = $cleanedDescription.Trim()

# Project is the part before the first backslash in Area
$project = ""
if ($area -match '^(.*?)\\\\') {
    $project = $matches[1]
}
elseif ($area) {
    $project = $area
}

# Output for GitHub Actions (Environment Files method)
"title=$IssueTitle" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
"description=$cleanedDescription" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
"area=$area" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
"parent=$parent" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
"project=$project" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
