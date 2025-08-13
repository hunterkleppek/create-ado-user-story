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

# Clean description - remove the metadata
$cleanDescription = $IssueBody `
    -replace "Area:\s*([^\r\n]+)", "" `
    -replace "Parent:\s*([^\r\n]+)", ""
$cleanDescription = $cleanDescription.Trim()

# Output the parsed values for logging
Write-Host "Title=$IssueTitle"
Write-Host "Description=$cleanDescription"
Write-Host "Type=$workItemType"
Write-Host "Project=$project"
Write-Host "Area=$areaPath"
Write-Host "Parent=$parentId"

# Using echo to set GitHub Actions outputs (modern approach)
Write-Host "title=$IssueTitle" >> $env:GITHUB_OUTPUT
Write-Host "clean_description=$cleanDescription" >> $env:GITHUB_OUTPUT
Write-Host "type=$workItemType" >> $env:GITHUB_OUTPUT
Write-Host "project=$project" >> $env:GITHUB_OUTPUT
Write-Host "area=$areaPath" >> $env:GITHUB_OUTPUT
Write-Host "parent=$parentId" >> $env:GITHUB_OUTPUT

# Return a result object for workflow_dispatch context
return @{
    title       = $IssueTitle
    description = $cleanDescription
    type        = $workItemType
    project     = $project
    area        = $areaPath
    parent      = $parentId
}
