# Example: How to Call the Workflow

Here's a complete example showing how to trigger the workflow to create a work item in Azure DevOps using service principal authentication.

## Manual Workflow Trigger (from GitHub UI)

1. Go to your repository on GitHub
2. Click on the "Actions" tab
3. Select the "Create ADO Work Item using Service Principal" workflow
4. Click on "Run workflow"
5. Fill in the form:
   - **Title**: "Implement user authentication feature"
   - **Description**: "Add OAuth2 authentication to allow users to log in with their Microsoft accounts"
   - **Type**: "User Story"
   - **ADO Organization**: "contoso"
   - **ADO Project**: "marketing-website"
   - **ADO Parent ID**: "45123"
   - **Area Path**: "MyProject\\Security\\Authentication"
6. Click "Run workflow"

## Programmatic Trigger using GitHub CLI

You can also trigger the workflow programmatically using the GitHub CLI:

```bash
gh workflow run "Create ADO Work Item using Service Principal" \
  --ref main \
  --repo hu03939_secura/create-ado-user-story \
  --field title="Implement user authentication feature" \
  --field description="Add OAuth2 authentication to allow users to log in with their Microsoft accounts" \
  --field type="User Story" \
  --field ado-organization="contoso" \
  --field ado-project="marketing-website" \
  --field ado-parent-id="45123" \
  --field ado-area="MyProject\\Security\\Authentication" \
```


## Trigger from GitHub Issue

The workflow will automatically run when a new issue is created in your repository. Just create an issue with a descriptive title and body, and a corresponding work item will be created in Azure DevOps.


### Using Labels to Control Work Item Type

- Add labels like `bug`, `task`, `feature`, or `epic` to your issue to control the Azure DevOps work item type. If none of these labels are present, the default is **User Story**.


#### Example

1. Create a new GitHub issue with:
  - Title: "API returns 500 error on POST"
  - Description:
    ```
    When submitting a POST request to /api/orders, the API returns a 500 error.

    Area: Backend\API
    Parent: 12345
    ```
  - Labels: `bug`

2. The workflow will create a **Bug** work item in Azure DevOps with:
  - Area Path: Backend\API
  - Parent: 12345

## Example REST API Call

If you want to trigger the workflow via the GitHub API:

```bash
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token YOUR_GITHUB_PAT" \
  https://api.github.com/repos/hu03939_secura/create-ado-user-story/actions/workflows/create-workitem-with-sp.yml/dispatches \
  -d '{
    "ref": "main",
    "inputs": {
      "title": "Implement user authentication feature",
      "description": "Add OAuth2 authentication to allow users to log in with their Microsoft accounts",
      "type": "User Story",
      "ado-organization": "contoso",
      "ado-project": "marketing-website",
      "ado-parent-id": "45123",
      "ado-area": "MyProject\\\\Security\\\\Authentication"
    }
  }'
```

## Integration in Another Workflow

You can also call this workflow from another workflow:

```yaml
name: Create Work Item from PR

on:
  pull_request:
    types: [opened]

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
          ado_organization: 'YourADOOrg'
      
      - name: Create ADO Work Item
        run: |
          $scriptPath = Join-Path -Path ${{ github.workspace }} -ChildPath "PowerShell/create-ado-story.ps1"
          & $scriptPath `
            -Organization "YourADOOrg" `
            -Project "YourProject" `
            -BearerToken "${{ steps.get-token.outputs.ado_token }}" `
            -IssueTitle "PR: ${{ github.event.pull_request.title }}" `
            -IssueBody "${{ github.event.pull_request.body }}" `
            -WorkItemType "Task" `
            -ParentId "12345" `
            -AreaPath "YourProject\\Development\\PRs"
        shell: pwsh
```

## Complete Setup Example

Here's a full configuration example to set up and use the integration:

1. **Create secrets in GitHub repository**:
   - `ADO_SP_CLIENT_ID`: `11a22b33-4c55-6d77-8e99-0f1a2b3c4d5e`
   - `ADO_SP_TENANT_ID`: `aaaabbbb-cccc-dddd-eeee-ffff00001111`
   - `ADO_SP_CLIENT_SECRET`: `[Your secure client secret]`

2. **Configure your workflow file**:
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
        description: 'Type of the work item'
        required: true
        default: 'User Story'
      ado-organization:
        description: 'Azure DevOps organization'
        required: true
        default: 'contoso'
      ado-project:
        description: 'Azure DevOps project'
        required: true
        default: 'marketing-website' 
      ado-parent-id:
        description: 'ID of the parent work item'
        required: false
        default: '45123'
      ado-area:
        description: 'Area path for the work item'
        required: false
        default: 'MyProject\\Security\\Authentication'
   
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
         
         - name: Create ADO Work Item
           run: |
             $scriptPath = Join-Path -Path ${{ github.workspace }} -ChildPath "PowerShell/create-ado-story.ps1"
             $tagsParam = @()
             if ("${{ github.event.inputs.ado-tags }}" -ne "") {
               $tagsParam = "${{ github.event.inputs.ado-tags }}".Split(',')
             }
             & $scriptPath `
               -Organization "${{ github.event.inputs.ado-organization }}" `
               -Project "${{ github.event.inputs.ado-project }}" `
               -BearerToken "${{ steps.get-token.outputs.ado_token }}" `
               -IssueTitle "${{ github.event.inputs.title }}" `
               -IssueBody "${{ github.event.inputs.description }}" `
               -WorkItemType "${{ github.event.inputs.type }}" `
               -ParentId "${{ github.event.inputs.ado-parent-id }}" `
               -Tags $tagsParam `
               -AreaPath "${{ github.event.inputs.ado-area }}"
           shell: pwsh
   ```

3. **Verify service principal in Azure DevOps**:
   - Navigate to `https://dev.azure.com/contoso/_settings/users`
   - Ensure your service principal appears in the list
   - Verify it has the necessary permissions

When the workflow runs, it will:
1. Get an access token from the service principal
2. Create a work item in the Azure DevOps project
3. Return the URL of the created work item

The workflow logs will show the URL of the newly created work item, which will look something like:
```
Created work item: https://dev.azure.com/contoso/marketing-website/_workitems/edit/12345
```
