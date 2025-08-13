[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$IssueTitle,
    
    [Parameter(Mandatory = $false)]
    [string]$IssueBody = ""
)

# Initialize default values
$workItemType = "User Story"
$project = "Suite"
$areaPath = "Suite\\Integrations - 1"
$parentId = ""
$cleanDescription = $IssueBody

# Extract metadata from issue body using regex
if ($IssueBody -match "Area:\s*(.*?)(\s+Parent:|$)") {
    $areaPath = $Matches[1].Trim()
}

if ($IssueBody -match "Parent:\s*['\""]?(\d+)['\""]?") {
    $parentId = $Matches[1].Trim()
} 

# Make sure we have a default area path even if extraction fails
if ([string]::IsNullOrWhiteSpace($areaPath)) {
    $areaPath = "Suite\\Integrations - 1"
}


# Improved description extraction: preserve any text after metadata on the same line
$cleanDescription = $IssueBody

# Remove Area and Parent metadata, but keep any text after them as description
if ($cleanDescription -match "Area:\s*([^\r\n]+)") {
    $cleanDescription = $cleanDescription -replace "Area:\s*([^\r\n]+)", ""
}
if ($cleanDescription -match "Parent:\s*([^\r\n]+)") {
    $cleanDescription = $cleanDescription -replace "Parent:\s*([^\r\n]+)", ""
}
$cleanDescription = $cleanDescription.Trim()

# Output the parsed values for logging
Write-Host "Title=$IssueTitle"
Write-Host "Description=$cleanDescription"
Write-Host "Type=$workItemType"
Write-Host "Project=$project"
Write-Host "Area=$areaPath"
Write-Host "Parent=$parentId"

# Set outputs for GitHub Actions if running in Actions context
if ($env:GITHUB_OUTPUT) {
    @(
        "title=$IssueTitle"
        "description=$cleanDescription"
        "type=$workItemType"
        "project=$project"
        "area=$areaPath"
        "parent=$parentId"
    ) | ForEach-Object { Add-Content -Path $env:GITHUB_OUTPUT -Value $_ }
}

# Return a result object for local/test context
return @{
    title       = $IssueTitle
    description = $cleanDescription
    type        = $workItemType
    project     = $project
    area        = $areaPath
    parent      = $parentId
}
