param(
    [string]$Organization = "<your-org>",
    [string]$Project = "<your-project>",
    [string]$Pat = "",
    [string]$BearerToken = "",
    [string]$Title = "Sample Work Item",
    [string]$Description = "Created via PowerShell",
    [string]$WorkItemType = "Issue",
    [string]$ParentId = ""
)

$Uri = "https://dev.azure.com/$Organization/$Project/_apis/wit/workitems/`$$($WorkItemType)?api-version=7.0"

# Set up authentication header based on what was provided
if (-not [string]::IsNullOrEmpty($BearerToken)) {
    Write-Host "Using Bearer token authentication"
    $Headers = @{
        Authorization  = "Bearer $BearerToken"
        "Content-Type" = "application/json-patch+json"
    }
} 
elseif (-not [string]::IsNullOrEmpty($Pat)) {
    Write-Host "Using PAT authentication"
    $Headers = @{
        Authorization  = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
        "Content-Type" = "application/json-patch+json"
    }
}
else {
    throw "Either PAT or BearerToken must be provided for authentication"
}

$Body = @(
    @{
        op    = "add"
        path  = "/fields/System.Title"
        value = $Title
    },
    @{
        op    = "add"
        path  = "/fields/System.Description"
        value = $Description
    }
) | ConvertTo-Json

$response = Invoke-RestMethod -Uri $Uri -Method POST -Headers $Headers -Body $Body
$response
