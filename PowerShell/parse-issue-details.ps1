param (
    [string]$IssueTitle,
    [string]$IssueBody
)

# Extract Area and Parent (handle single-quoted or unquoted values)
$area = ""
$parent = ""

if ($IssueBody -match "Area:\s*'([^']+)'|Area:\s*([^\s]+)") {
    $area = if ($matches[1]) { $matches[1].Trim() } else { $matches[2].Trim() }
}
if ($IssueBody -match "Parent:\s*'([^']+)'|Parent:\s*([^\s]+)") {
    $parent = if ($matches[1]) { $matches[1].Trim() } else { $matches[2].Trim() }
}

# Remove Area and Parent from description
$cleanedDescription = $IssueBody -replace "Area:\s*'[^']+'", ''
$cleanedDescription = $cleanedDescription -replace "Area:\s*[^\s]+", ''
$cleanedDescription = $cleanedDescription -replace "Parent:\s*'[^']+'", ''
$cleanedDescription = $cleanedDescription -replace "Parent:\s*[^\s]+", ''
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
