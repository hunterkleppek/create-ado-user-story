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

# Echo results to the console
Write-Host "Parsed Title: $IssueTitle"
Write-Host "Parsed Description: $cleanedDescription"
Write-Host "Parsed Area: $area"
Write-Host "Parsed Parent: $parent"
Write-Host "Parsed Project: $project"
