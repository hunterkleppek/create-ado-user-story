param (
    [string]$Organization,
    [string]$Project,
    [string]$Title,
    [string]$Description,
    [string]$WorkItemType,
    [string]$ParentId,
    [string]$AreaPath,
    [string]$TagsString,
    [string]$BearerToken,
    [string]$Pat
)

$scriptPath = Join-Path -Path $env:GITHUB_WORKSPACE -ChildPath "PowerShell/create-ado-story.ps1"

# Process tags if provided
$tagsParam = @()
if ($TagsString -ne "") {
    $tagsParam = $TagsString.Split(',')
}

# Use the correct authentication method
if ($BearerToken -ne "") {
    # Use bearer token authentication
    & $scriptPath `
        -Organization $Organization `
        -Project $Project `
        -BearerToken $BearerToken `
        -IssueTitle $Title `
        -IssueBody $Description `
        -WorkItemType $WorkItemType `
        -ParentId $ParentId `
        -Tags $tagsParam `
        -AreaPath $AreaPath
} else {
    # Use PAT authentication
    & $scriptPath `
        -Organization $Organization `
        -Project $Project `
        -Pat $Pat `
        -IssueTitle $Title `
        -IssueBody $Description `
        -WorkItemType $WorkItemType `
        -ParentId $ParentId `
        -Tags $tagsParam `
        -AreaPath $AreaPath
}