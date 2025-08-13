param (
    [string]$IssueTitle,
    [string]$IssueBody,
    [string]$IssueLabels
)

# Default work item type
$workItemType = "User Story"

# Extract Area and Parent from description
if ($IssueBody -match "Area:\s*(.+)$") {
    $areaPath = $matches[1].Trim()
    Write-Host "Found Area Path: $areaPath"
    echo "area=$areaPath" >> $env:GITHUB_OUTPUT
}
else {
    $areaPath = ""
}

if ($IssueBody -match "Parent:\s*(\d+)") {
    $parentId = $matches[1].Trim()
    Write-Host "Found Parent ID: $parentId"
    echo "parent=$parentId" >> $env:GITHUB_OUTPUT
}
else {
    $parentId = ""
}

# Clean the description by removing Area and Parent lines
$cleanedDescription = $IssueBody -replace "Area:.*", "" -replace "Parent:.*", ""
$cleanedDescription = $cleanedDescription.Trim()

# Project is the part before the first backslash in Area
$project = ""
if ($areaPath -match '^(.*?)\\\\') {
    $project = $matches[1]
}
elseif ($areaPath) {
    $project = $areaPath
}

# Check for specific labels and map them to work item types
if ($IssueLabels -match "bug") {
    $workItemType = "Bug"
}
elseif ($IssueLabels -match "task") {
    $workItemType = "Task"
}
elseif ($IssueLabels -match "epic") {
    $workItemType = "Epic"
}
elseif ($IssueLabels -match "feature") {
    $workItemType = "Feature"
}

echo "title=$IssueTitle" >> $env:GITHUB_OUTPUT
echo "description=$cleanedDescription" >> $env:GITHUB_OUTPUT
echo "type=$workItemType" >> $env:GITHUB_OUTPUT

# Output additional fields for GitHub Actions
Write-Host "::set-output name=title::$IssueTitle"
Write-Host "::set-output name=description::$cleanedDescription"
Write-Host "::set-output name=area::$areaPath"
Write-Host "::set-output name=parent::$parentId"
Write-Host "::set-output name=project::$project"
