<#
.SYNOPSIS
    Generates an access token for Azure DevOps using a service principal.

.DESCRIPTION
    This script generates an access token for Azure DevOps using service principal credentials.
    The token can be used to authenticate with Azure DevOps REST APIs.

.PARAMETER TenantId
    The Azure AD tenant ID where the service principal is registered.

.PARAMETER ClientId
    The application (client) ID of the service principal.

.PARAMETER ClientSecret
    The client secret of the service principal.

.PARAMETER Organization
    The name of your Azure DevOps organization (without the URL).

.EXAMPLE
    .\Get-AzureDevOpsToken.ps1 -TenantId "00000000-0000-0000-0000-000000000000" -ClientId "11111111-1111-1111-1111-111111111111" -ClientSecret "your-client-secret" -Organization "contoso"

.NOTES
    This script requires the service principal to have been granted permission to access Azure DevOps.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$TenantId,
    
    [Parameter(Mandatory = $true)]
    [string]$ClientId,
    
    [Parameter(Mandatory = $true)]
    [string]$ClientSecret,
    
    [Parameter(Mandatory = $true)]
    [string]$Organization
)

# Azure DevOps App ID (this is a well-known ID)
$adoAppId = "499b84ac-1321-427f-aa17-267ca6975798"

# Get access token
Write-Host "Requesting access token for Azure DevOps..." -ForegroundColor Cyan
$tokenUrl = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
$body = @{
    client_id     = $ClientId
    scope         = "$adoAppId/.default"
    client_secret = $ClientSecret
    grant_type    = "client_credentials"
}

try {
    $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body
    $token = $response.access_token
    
    # Verify the token by making a test request
    Write-Host "Verifying token with a test API call..." -ForegroundColor Cyan
    $apiUrl = "https://dev.azure.com/$Organization/_apis/projects?api-version=7.0"
    $headers = @{
        Authorization = "Bearer $token"
    }
    
    $projectsResponse = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
    
    Write-Host "Token successfully verified!" -ForegroundColor Green
    Write-Host "Found $($projectsResponse.count) projects in organization '$Organization'" -ForegroundColor Green
    
    # Output token information
    Write-Host "`nAccess Token Information:" -ForegroundColor Cyan
    Write-Host "------------------------" -ForegroundColor Cyan
    Write-Host "Organization: $Organization" -ForegroundColor White
    Write-Host "Token Type: Bearer" -ForegroundColor White
    
    # Calculate token expiration
    $tokenParts = $token.Split('.')
    if ($tokenParts.Length -gt 1) {
        $tokenPayload = $tokenParts[1].Replace('-', '+').Replace('_', '/')
        while ($tokenPayload.Length % 4) { $tokenPayload += "=" }
        $tokenJson = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($tokenPayload))
        $tokenData = ConvertFrom-Json $tokenJson
        
        if ($tokenData.exp) {
            $epoch = [DateTimeOffset]::FromUnixTimeSeconds($tokenData.exp)
            $expiration = $epoch.LocalDateTime
            $timeLeft = $expiration - (Get-Date)
            Write-Host "Expiration: $expiration (expires in $([math]::Round($timeLeft.TotalMinutes)) minutes)" -ForegroundColor White
        }
    }
    
    Write-Host "`nToken (for use in Bearer authentication header):" -ForegroundColor Cyan
    Write-Output $token
    
    # Example code snippet
    Write-Host "`nExample usage in PowerShell:" -ForegroundColor Cyan
    Write-Host "------------------------" -ForegroundColor Cyan
    Write-Host '$token = "' + $token.Substring(0, 20) + '..."  # Your full token here' -ForegroundColor White
    Write-Host '$headers = @{ Authorization = "Bearer $token" }' -ForegroundColor White
    Write-Host '$response = Invoke-RestMethod -Uri "https://dev.azure.com/' + $Organization + '/_apis/projects?api-version=7.0" -Headers $headers' -ForegroundColor White
    Write-Host '$response.value  # Shows list of projects' -ForegroundColor White
    
    return $token
}
catch {
    Write-Host "Error obtaining or verifying token: $_" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
    
    # Additional troubleshooting information
    if ($_.Exception.Response.StatusCode.value__ -eq 401) {
        Write-Host "`nAuthorization Error (401). Possible reasons:" -ForegroundColor Yellow
        Write-Host "1. The service principal doesn't have permission to access Azure DevOps" -ForegroundColor Yellow
        Write-Host "2. The client credentials (ID/secret) are incorrect" -ForegroundColor Yellow
        Write-Host "3. The service principal hasn't been added to the Azure DevOps organization" -ForegroundColor Yellow
    }
    
    exit 1
}
