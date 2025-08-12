# Using create-ado-user-story with Service Principal Authentication

This guide explains how to use the `create-ado-user-story` repository in conjunction with the `get-accesstoken-from-serviceprinciple-workflow` repository to create Azure DevOps work items using service principal authentication instead of Personal Access Tokens (PATs).

## Benefits of Using Service Principal Authentication

- **Enhanced security**: Microsoft Entra tokens expire hourly, reducing exposure risk compared to PATs (which can last up to one year)
- **Automatic rotation**: Managed identities handle credential rotation automatically
- **No stored secrets**: Eliminates the need to store long-lived credentials in code or configuration
- **Centralized management**: Control access through Microsoft Entra ID policies and Azure DevOps permissions

## Prerequisites

1. **Azure DevOps Organization** with appropriate permissions
2. **Microsoft Entra ID Service Principal** with access to your Azure DevOps organization
3. **GitHub repository** containing your workflow

## Setup Steps

### 1. Create a Service Principal in Microsoft Entra ID

1. Register an application in the [Microsoft Entra admin center](https://entra.microsoft.com/)
2. Go to App registrations > New registration
3. Configure the application:
   - Name: Descriptive name for your application
   - Account types: Select appropriate tenant support
   - Redirect URI: Leave blank for service-to-service scenarios
4. Create authentication credentials:
   - Recommended: Upload a certificate for enhanced security
   - Alternative: Create a client secret (requires regular rotation)

### 2. Add the Service Principal to Azure DevOps

1. Go to your Azure DevOps Organization settings > Users
2. Select Add user
3. Enter the display name of your service principal
4. Select the appropriate access level and project access
5. Send the invitation

### 3. Configure GitHub Repository Secrets

Add the following secrets to your GitHub repository:

- `ADO_SP_CLIENT_ID`: The client ID of your service principal
- `ADO_SP_TENANT_ID`: Your Microsoft Entra tenant ID
- `ADO_SP_CLIENT_SECRET`: The client secret of your service principal
- `GH_PAT`: A GitHub Personal Access Token with repo scope (if the accesstoken repo is private)

### 4. Create a Workflow File

Create a workflow file that:

1. Calls the `get-accesstoken-from-serviceprinciple-workflow` action to obtain an access token
2. Passes the token to the `create-ado-user-story` action to create a work item

## Sample Workflow

```yaml
name: 'Create ADO Work Item using Service Principal'

on:
  workflow_dispatch:
    inputs:
      title:
        description: 'Title of the work item'
        required: true
        default: 'New Work Item'
      description:
        description: 'Description of the work item'
        required: false
        default: ''
      type:
        description: 'Type of the work item (e.g., User Story, Task, Bug)'
        required: true
        default: 'User Story'
      ado-organization:
        description: 'Azure DevOps organization'
        required: true
      ado-project:
        description: 'Azure DevOps project'
        required: true
      ado-parent-id:
        description: 'ID of the parent work item (e.g., Epic ID)'
        required: false
        default: ''
      ado-area:
        description: 'Area path for the work item'
        required: false
      ado-tags:
        description: 'Comma-separated list of tags'
        required: false
        default: 'GitHub,AutoCreated'
  
  issues:
    types: [opened, edited]

jobs:
  create-work-item:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3
      
      - name: Checkout Token Generator
        uses: actions/checkout@v3
        with:
          repository: hu03939_secura/get-accesstoken-from-serviceprinciple-workflow
          path: get-token-repo
      
      - name: Get Azure DevOps Token
        id: get-token
        uses: ./get-token-repo
        with:
          client_id: ${{ secrets.ADO_SP_CLIENT_ID }}
          tenant_id: ${{ secrets.ADO_SP_TENANT_ID }}
          client_secret: ${{ secrets.ADO_SP_CLIENT_SECRET }}
          ado_organization: ${{ github.event.inputs.ado-organization }}
      
      - name: Determine Title and Description
        id: work-item-details
        run: |
          if [[ "${{ github.event_name }}" == "issues" ]]; then
            echo "title=${{ github.event.issue.title }}" >> $GITHUB_OUTPUT
            echo "description=${{ github.event.issue.body }}" >> $GITHUB_OUTPUT
          else
            echo "title=${{ github.event.inputs.title }}" >> $GITHUB_OUTPUT
            echo "description=${{ github.event.inputs.description }}" >> $GITHUB_OUTPUT
          fi
        shell: bash
      
      - name: Create ADO Work Item
        run: |
          $scriptPath = Join-Path -Path ${{ github.workspace }} -ChildPath "PowerShell/create-ado-story.ps1"
          
          # Process tags if provided
          $tagsParam = @()
          if ("${{ github.event.inputs.ado-tags }}" -ne "") {
            $tagsParam = "${{ github.event.inputs.ado-tags }}".Split(',')
          }
          
          # Use service principal token
          & $scriptPath `
            -Organization "${{ github.event.inputs.ado-organization }}" `
            -Project "${{ github.event.inputs.ado-project }}" `
            -BearerToken "${{ steps.get-token.outputs.ado_token }}" `
            -IssueTitle "${{ steps.work-item-details.outputs.title }}" `
            -IssueBody "${{ steps.work-item-details.outputs.description }}" `
            -WorkItemType "${{ github.event.inputs.type || 'User Story' }}" `
            -ParentId "${{ github.event.inputs.ado-parent-id }}" `
            -Tags $tagsParam `
            -AreaPath "${{ github.event.inputs.ado-area }}"
        shell: pwsh
```

## Important Notes

1. The `get-accesstoken-from-serviceprinciple-workflow` repository provides a reusable workflow or action that obtains an access token from an Azure service principal.
2. The `create-ado-user-story` repository has been modified to accept both PAT and Bearer token authentication.
3. The access token is passed between jobs using job outputs.
4. You can trigger work item creation manually or automatically on issue creation/editing.

For complete examples of how to call this workflow in different scenarios, see [Example Usage](example-usage.md).

## Troubleshooting

- **Access Denied**: Ensure the service principal has the correct permissions in Azure DevOps.
- **Token Errors**: Verify the service principal credentials and that the service principal has been properly added to your Azure DevOps organization.
- **Workflow Errors**: Check that all repository paths and references are correct.

For more information, refer to the documentation on [service principals and managed identities in Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/service-principal-managed-identity).
