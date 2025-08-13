param (
    [string]$IssueTitle,
    [string]$IssueBody
)

# Extract Area and Parent (handle single-quoted values)
$area = ""
$parent = ""

if ($IssueBody -match "Area:\s*'([^']+)'") {
    $area = $matches[1].Trim()
}
if ($IssueBody -match "Parent:\s*'([^']+)'") {
    $parent = $matches[1].Trim()
}

# Remove Area and Parent from description
$cleanedDescription = $IssueBody -replace "Area:\s*'[^']+'", ''
$cleanedDescription = $cleanedDescription -replace "Parent:\s*'[^']+'", ''
$cleanedDescription = $cleanedDescription.Trim()

# Project is the part before the first backslash in Area
$project = ""
if ($area -match '^(.*?)\\\\') {
    $project = $matches[1]
}
elseif ($area) {
    $project = $area
}

# Echo results to the console
Write-Host "Parsed Title: $IssueTitle"
Write-Host "Parsed Description: $cleanedDescription"
Write-Host "Parsed Area: $area"
Write-Host "Parsed Parent: $parent"
Write-Host "Parsed Project: $project"
