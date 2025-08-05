param(
    [string]$Organization,
    [string]$Project,
    [string]$EpicId,
    [string]$Pat,
    [string]$WorkItemType = "User Story",
    [string]$AreaPath,
    [string]$Tags = "",
    [string]$RepositoryName = "",
    [string]$IssueTitle,
    [string]$IssueBody
)

# Process the title
if (-not [string]::IsNullOrEmpty($RepositoryName)) {
    $Title = "$RepositoryName - $IssueTitle"
}
else {
    $Title = $IssueTitle
}

# Escape backslashes in area path for JSON
$EscapedAreaPath = $AreaPath -replace '\\', '\\'

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
    },
    @{
        op    = "add"
        path  = "/fields/System.AreaPath"
        value = $EscapedAreaPath
    },
    @{
        op    = "add"
        path  = "/relations/-"
        value = @{
            rel = "System.LinkTypes.Hierarchy-Reverse"
            url = "https://dev.azure.com/$Organization/$Project/_apis/wit/workItems/$EpicId"
        }
    }
)

# Add tags if provided
if (-not [string]::IsNullOrEmpty($Tags)) {
    $PatchDocument += @{
        op    = "add"
        path  = "/fields/System.Tags"
        value = $Tags
    }
}

# Convert to JSON with proper depth
$JsonPayload = $PatchDocument | ConvertTo-Json -Depth 5

# Encode work item type for URL
$WorkItemTypeEncoded = [Uri]::EscapeDataString($WorkItemType)
$CreateUrl = "https://dev.azure.com/$Organization/$Project/_apis/wit/workitems/`$$WorkItemTypeEncoded" + "?api-version=7.0"

# Set up authorization header
$Base64Pat = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
$Headers = @{
    Authorization  = "Basic $Base64Pat"
    "Content-Type" = "application/json-patch+json"
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
