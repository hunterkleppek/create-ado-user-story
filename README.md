# Create ADO User Story GitHub Action

This GitHub Action creates a user story (or other work item type) in Azure DevOps from a GitHub issue. It is designed to be reusable and configurable for different organizations, projects, and boards.

## Inputs

| Name                | Required | Description                                                                                 |
|---------------------|----------|---------------------------------------------------------------------------------------------|
| `ado-organization`  | Yes      | Azure DevOps organization name                                                              |
| `ado-project`       | Yes      | Azure DevOps project name                                                                   |
| `ado-parent-id`     | No       | Azure DevOps Parent ID to link the new work item as a child                                 |
| `type`              | No       | Azure DevOps Work Item Type (e.g., User Story, Product Backlog Item, Bug). Default: User Story |
| `ado-area`          | No       | Azure DevOps Area Path for the work item                                                    |
| `ado-tags`          | No       | Comma-separated list of tags to apply to the work item                                      |
| `title`             | Yes      | Title of the work item                                                                      |
| `description`       | No       | Description of the work item                                                                |

## Usage Example

```yaml
jobs:
  create-ado-story:
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
          ado_organization: 'TestOrg'
      
      - name: Create ADO Work Item
        run: |
          $scriptPath = Join-Path -Path ${{ github.workspace }} -ChildPath "PowerShell/create-ado-story.ps1"
          & $scriptPath `
            -Organization "TestOrg" `
            -Project "TestProject" `
            -BearerToken "${{ steps.get-token.outputs.ado_token }}" `
            -IssueTitle "New Feature Request" `
            -IssueBody "This is a detailed description of the feature" `
            -WorkItemType "User Story" `
            -ParentId "45879" `
            -Tags @("GitHub", "AutoCreated") `
            -AreaPath "TestProject\\TestingBoard"
        shell: pwsh
```

## How It Works
- Creates a work item in Azure DevOps using the title and description provided through workflow inputs
- Optionally uses GitHub issue title and body when triggered from an issue
- Sets area path, tags, and links the new work item to the specified parent work item
- Uses the PowerShell script to interact with the Azure DevOps API
- Outputs the created work item link or an error message

## Requirements
- The runner must have PowerShell installed (default on all runners)
- For service principal authentication, you'll need:
  - Azure DevOps service principal (client ID, tenant ID, and client secret)
  - Appropriate permissions for the service principal in Azure DevOps

## Authentication Options
This action supports two authentication methods:
1. **Personal Access Token (PAT)**: Traditional method using PATs stored as secrets
2. **Service Principal Authentication**: More secure method using Microsoft Entra service principals

For information on using service principal authentication, see:
- [Service Principal Integration](docs/service-principal-integration.md)
- [Example Usage](docs/example-usage.md)


## GitHub Issue Integration

This workflow can automatically create Azure DevOps work items from GitHub issues. The workflow uses the following logic:

- **Work Item Type Mapping:**
  - If the issue has a label `bug`, the work item type will be **Bug**
  - If the issue has a label `task`, the work item type will be **Task**
  - If the issue has a label `feature`, the work item type will be **Feature**
  - If the issue has a label `epic`, the work item type will be **Epic**
  - If none of these labels are present, the default is **User Story**

- **Area Path and Parent ID:**
  - You can specify an Area Path and Parent ID in the issue body using lines like:
    - `Area: Project\Area\SubArea`
    - `Parent: 12345`
  - These lines will be removed from the work item description

For more details and examples, see:
- [Issue Standard Layout](docs/issue-standard-layout.md)

## Notes
- The action is designed for use in workflows triggered by GitHub issues.
- The area path must use double backslashes (`\\`) in YAML to escape for JSON.
- If `repository-name` is not provided, the title will not have a leading dash.

---

For questions or issues, please open an issue in this repository.

