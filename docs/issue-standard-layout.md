# GitHub Issue to Azure DevOps Work Item Mapping

This guide explains how to use GitHub issues to create Azure DevOps work items with this workflow.


## Work Item Type Mapping

When an issue is created or edited, the workflow checks for specific labels to determine the work item type:

| GitHub Label | ADO Work Item Type |
|--------------|-------------------|
| `bug`        | Bug               |
| `task`       | Task              |
| `epic`       | Epic              |
| `feature`    | Feature           |
| *(none of the above)* | User Story (default) |

If multiple of these labels are present, the first match in the order above is used.

## Tags

All GitHub issue labels are added as tags to the Azure DevOps work item, along with:
- `GitHub`
- `Issue#{issue-number}`

## Specifying Area Path and Parent ID in the Description

You can include special metadata in your issue description to set the Area Path and Parent ID:

### Area Path

To specify an area path, include a line in your issue description:

Area: Project\Area\SubArea

Example: `Area: Marketing\Website\Frontend`

### Parent Work Item

To specify a parent work item ID, include a line in your issue description:

Parent: 12345

Where 12345 is the ID of the parent work item in Azure DevOps.

> **Note:** These metadata lines will be automatically removed from the description when creating the work item in Azure DevOps.

## Example: Complete Issue Setup

1. Create a new GitHub issue with a title and description
2. In the description, include:

Description text goes here...

Area: Project\Web\API Parent: 9876

3. Add the label `feature` (to create a Feature work item)
4. Add additional labels like `priority-high` and `frontend` (will be added as tags)

This will create a Feature work item in Azure DevOps with:
- Area Path: Project\Web\API
- Parent: 9876
- Tags: feature, priority-high, frontend, GitHub, Issue#{issue-number}

## Specifying Area Path and Parent ID in the Description

You can include special metadata in your issue description to set the Area Path and Parent ID:

### Area Path

To specify an area path, include a line in your issue description:

Area: Project\Area\SubArea


Example: `Area: Marketing\Website\Frontend`

### Parent Work Item

To specify a parent work item ID, include a line in your issue description:

Parent: 12345


Where 12345 is the ID of the parent work item in Azure DevOps.

> **Note:** These metadata lines will be automatically removed from the description when creating the work item in Azure DevOps.

## Tags

All GitHub issue labels will be added as tags to the Azure DevOps work item, along with:
- `GitHub` 
- `Issue#{issue-number}`

## Example: Complete Issue Setup

1. Create a new GitHub issue with a title and description
2. In the description, include:

Description text goes here...

Area: Project\Web\API Parent: 9876

3. Add the label `feature` (to create a Feature work item)
4. Add additional labels like `priority-high` and `frontend` (will be added as tags)

This will create a Feature work item in Azure DevOps with:
- Area Path: Project\Web\API
- Parent: Work item #9876
- Tags: GitHub, Issue#{issue-number}, priority-high, frontend
- Description: "Description text goes here..." (metadata lines removed)

## Default Settings for Issue-Triggered Work Items

When the workflow is triggered by an issue and no specific organization or project is configured, the workflow will use:
- Organization: "DefaultOrg" (you should change this in the workflow file)
- Project: "DefaultProject" (you should change this in the workflow file)

To customize these defaults, edit the workflow file and update the fallback values.
