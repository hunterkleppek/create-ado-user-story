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
if ($IssueBody -match "Area:\s*([^\r\n]+)") {
    $areaPath = $Matches[1].Trim()
}

if ($IssueBody -match "Parent:\s*([^\r\n]+)") {
    $parentId = $Matches[1].Trim()
}


# Clean description - remove the metadata
$cleanDescription = $IssueBody `
    -replace "Area:\s*([^\r\n]+)", "" `
    -replace "Parent:\s*([^\r\n]+)", ""
$cleanDescription = $cleanDescription.Trim()

# Output the parsed values
Write-Host "Title: $IssueTitle"
Write-Host "Clean Description: $cleanDescription"
Write-Host "Type: $workItemType"
Write-Host "Project: $project"
Write-Host "Area: $areaPath"
Write-Host "Parent: $parentId"

# Set GitHub Actions outputs
Write-Output "::set-output name=title::$IssueTitle"
Write-Output "::set-output name=clean_description::$cleanDescription"
Write-Output "::set-output name=type::$workItemType" 
Write-Output "::set-output name=project::$project"
Write-Output "::set-output name=area::$areaPath"
Write-Output "::set-output name=parent::$parentId"

# Return a result object for workflow_dispatch context
return @{
    title       = $IssueTitle
    description = $cleanDescription
    type        = $workItemType
    project     = $project
    area        = $areaPath
    parent      = $parentId
}
