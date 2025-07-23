# Create ADO User Story GitHub Action

This GitHub Action creates a user story (or other work item type) in Azure DevOps from a GitHub issue. It is designed to be reusable and configurable for different organizations, projects, and boards.

## Inputs

| Name              | Required | Description                                                                                 |
|-------------------|----------|---------------------------------------------------------------------------------------------|
| `ado-org`         | Yes      | Azure DevOps organization name                                                              |
| `ado-project`     | Yes      | Azure DevOps project name                                                                   |
| `ado-epic-id`     | Yes      | Azure DevOps Epic ID to link the new work item as a child                                   |
| `ado-work-item-type` | No   | Azure DevOps Work Item Type (e.g., User Story, Product Backlog Item, Bug). Default: User Story |
| `ado-area`        | Yes      | Azure DevOps Area Path for the work item                                                    |
| `ado-tags`        | No       | Comma-separated list of tags to apply to the work item                                      |
| `repository-name` | No       | The repository name to be prepended to the work item title                                  |

## Usage Example

```yaml
jobs:
  create-ado-story:
    runs-on: ubuntu-latest
    steps:
      - uses: your-org/your-repo@main
        with:
          ado-org: 'TestOrg'
          ado-project: 'TestProject'
          ado-epic-id: '45879'
          ado-work-item-type: 'User Story'
          ado-area: 'TestProject\\TestingBoard'
          ado-tags: "Innovation Backlog"
          repository-name: 'TestActionRepo'
```

## How It Works
- Takes the GitHub issue title and body as the work item title and description.
- Optionally prepends the repository name to the title.
- Sets area path, tags, and links the new work item to the specified Epic.
- Uses jq to build a valid JSON patch document for the Azure DevOps API.
- Outputs the created work item link or an error message.

## Requirements
- The runner must have `jq` and `curl` installed (default on Ubuntu runners).


## Notes
- The action is designed for use in workflows triggered by GitHub issues.
- The area path must use double backslashes (`\\`) in YAML to escape for JSON.
- If `repository-name` is not provided, the title will not have a leading dash.

---

For questions or issues, please open an issue in this repository.
