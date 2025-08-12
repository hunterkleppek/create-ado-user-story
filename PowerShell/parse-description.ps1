param (
    [string]$IssueBody
)

# Extract Area Path if present
$areaMatch = $IssueBody | Select-String -Pattern "Area:\s*(.+)$" -AllMatches
if ($areaMatch.Matches.Count -gt 0) {
    $areaPath = $areaMatch.Matches[0].Groups[1].Value.Trim()
    Write-Host "Found Area Path: $areaPath"
    echo "area=$areaPath" >> $env:GITHUB_OUTPUT
}

# Extract Parent ID if present
$parentMatch = $IssueBody | Select-String -Pattern "Parent:\s*(\d+)" -AllMatches
if ($parentMatch.Matches.Count -gt 0) {
    $parentId = $parentMatch.Matches[0].Groups[1].Value.Trim()
    Write-Host "Found Parent ID: $parentId"
    echo "parent=$parentId" >> $env:GITHUB_OUTPUT
}

# Clean the description by removing Area and Parent lines
$cleanedBody = $IssueBody -replace "Area:.*", "" -replace "Parent:.*", ""
$cleanedBody = $cleanedBody.Trim()
echo "clean_description=$cleanedBody" >> $env:GITHUB_OUTPUT