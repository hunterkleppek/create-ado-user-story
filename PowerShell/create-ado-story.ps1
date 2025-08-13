param(
    [string]$Organization,
    [string]$Project,
    [string]$BearerToken,
    [string]$WorkItemType = "User Story",
    [string]$AreaPath,
    [string]$IssueTitle,
    [string]$IssueBody,
    [string]$ParentId = ""  # Can be used instead of EpicId
)

# Echo all inputs for debugging
Write-Host "--- INPUTS ---"
Write-Host "Organization: $Organization"
Write-Host "Project: $Project"
Write-Host "BearerToken: $BearerToken"
Write-Host "WorkItemType: $WorkItemType"
Write-Host "AreaPath: $AreaPath"
Write-Host "IssueTitle: $IssueTitle"
Write-Host "IssueBody: $IssueBody"
Write-Host "ParentId: $ParentId"
Write-Host "--- END INPUTS ---"

# Validation block for required parameters
if (-not $Organization -or $Organization -eq "") {
    Write-Error "Organization is required and cannot be empty."
    throw "Organization is required."
}
if (-not $Project -or $Project -eq "") {
    Write-Error "Project is required and cannot be empty."
    throw "Project is required."
}
if (-not $WorkItemType -or $WorkItemType -eq "") {
    Write-Error "WorkItemType is required and cannot be empty."
    throw "WorkItemType is required."
}
if (-not $Title -or $Title -eq "") {
    Write-Error "Title is required and cannot be empty."
    throw "Title is required."
}
if (-not $IssueBody -or $IssueBody -eq "") {
    Write-Error "Description is required and cannot be empty."
    throw "Description is required."
}

# Ensure WorkItemType is set to a default if empty
if (-not $WorkItemType -or $WorkItemType -eq "") {
    $WorkItemType = "User Story"
    Write-Host "WorkItemType was empty, set to default: $WorkItemType"
}

# Process the title
if (-not [string]::IsNullOrEmpty($RepositoryName)) {
    $Title = "$RepositoryName - $IssueTitle"
}
else {
    $Title = $IssueTitle
}

# Escape backslashes in area path for JSON
$EscapedAreaPath = $AreaPath -replace '\\', '\\'

# Ensure AreaPath is set to a default if empty
if (-not $AreaPath -or $AreaPath -eq "") {
    $AreaPath = "Suite\\\\Integrations - 1"
    Write-Host "AreaPath was empty, set to default: $AreaPath"
}

# Determine which parent ID to use (EpicId or ParentId)
$ParentWorkItemId = if (-not [string]::IsNullOrEmpty($ParentId)) { $ParentId } else { $EpicId }

# Build the base JSON patch document
$PatchDocument = @(
    @{
        op    = "add"
        path  = "/fields/System.Title"
        value = $Title
    },
    @{
        op    = "add"
        path  = "/fields/System.Description"
        value = $IssueBody
    }
)
# Add area path if provided
if (-not [string]::IsNullOrEmpty($AreaPath)) {
    $PatchDocument += @{
        op    = "add"
        path  = "/fields/System.AreaPath"
        value = $EscapedAreaPath
    }
}

# Add parent link if parent ID is provided
if (-not [string]::IsNullOrEmpty($ParentWorkItemId)) {
    $PatchDocument += @{
        op    = "add"
        path  = "/relations/-"
        value = @{
            rel = "System.LinkTypes.Hierarchy-Reverse"
            url = "https://dev.azure.com/$Organization/$Project/_apis/wit/workItems/$ParentWorkItemId"
        }
    }
}

# Add tags if provided
if ($Tags -and $Tags.Count -gt 0) {
    $TagsString = $Tags -join "; "
    $PatchDocument += @{
        op    = "add"
        path  = "/fields/System.Tags"
        value = $TagsString
    }
}

# Convert to JSON with proper depth
$JsonPayload = $PatchDocument | ConvertTo-Json -Depth 5

# Encode work item type for URL
$WorkItemTypeEncoded = [Uri]::EscapeDataString($WorkItemType)
$CreateUrl = "https://dev.azure.com/$Organization/$Project/_apis/wit/workitems/`$$WorkItemTypeEncoded" + "?api-version=7.0"

# Set up authorization header
$Headers = @{
    "Content-Type" = "application/json-patch+json"
}

# Add appropriate authorization header based on provided authentication method
if (-not [string]::IsNullOrEmpty($Pat)) {
    # Use PAT authentication
    $Base64Pat = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
    $Headers["Authorization"] = "Basic $Base64Pat"
}
elseif (-not [string]::IsNullOrEmpty($BearerToken)) {
    # Use OAuth Bearer token (from service principal)
    $Headers["Authorization"] = "Bearer $BearerToken"
}
else {
    Write-Error "Either Pat or BearerToken must be provided for authentication"
    throw "Authentication method required"
}

# Send request to create work item
try {
    $Response = Invoke-RestMethod -Uri $CreateUrl -Method Patch -Headers $Headers -Body $JsonPayload
    $WorkItemId = $Response.id
    $StoryUrl = "https://dev.azure.com/$Organization/$Project/_workitems/edit/$WorkItemId"
    Write-Output "Created work item: $StoryUrl"
    
    # Return the work item object for potential further processing
    return $Response
}
catch {
    Write-Error "Failed to create work item: $_"
    throw
}
