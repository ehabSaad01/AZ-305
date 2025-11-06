# Day 01 — Governance & RBAC (AZ-305)

## Goals
- Enforce secure-by-default governance.
- Organize resources with a dedicated RG and tags.
- Apply least-privilege RBAC with a custom role.
- Export Activity Logs to Log Analytics for KQL and alerts.

## Implemented
- Resource Group: `rg-day01-governance-weu` (West Europe)
- Tags: `Environment=Dev`, `Owner=Ehab.Saad`, `Project=AZ-305`, `CostCenter=GOV01`
- Log Analytics Workspace: `log-day01-gov-weu`
- Subscription diagnostic setting: `diag-activitylogs-weu` → workspace `log-day01-gov-weu`
- Custom Role: `Reader-Storage-Limited`
  - Actions:
    - `Microsoft.Storage/storageAccounts/read`
    - `Microsoft.Storage/storageAccounts/blobServices/containers/read`
  - AssignableScopes:
    - `/subscriptions/6fa98ff9-39fd-4547-9fd4-e27fb267d465/resourceGroups/rg-day01-governance-weu`
- Role assignment: custom role assigned at RG scope to a specific ObjectId.

## KQL (verification)
```kql
AzureActivity
| where TimeGenerated > ago(24h)
| where tolower(OperationNameValue) has_any ("microsoft.authorization/roleassignments", "microsoft.resources/tags/write")
| project TimeGenerated, Category, OperationName, OperationNameValue, ResourceId, SubscriptionId, Caller, ActivityStatus
| order by TimeGenerated desc
Notes
Avoid duplicate diagnostic settings per category for the same sink.

Use one setting (diag-activitylogs-weu) for all categories.

Test pipeline by writing a temporary tag to the RG.

Next
Mirror with CLI and PowerShell (see scripts/).

Add screenshots in a later commit if needed.
