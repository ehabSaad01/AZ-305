# Day 01 — Governance & RBAC (AZ-305)

## Goals
- Secure-by-default governance.
- RG + tags.
- Custom RBAC role (no assignment in templates).
- Activity Logs → Log Analytics.

## Implemented
- RG: `rg-day01-governance-weu` (West Europe)
- Tags: `Environment=Dev`, `Owner=Ehab.Saad`, `Project=AZ-305`, `CostCenter=GOV01`
- Log Analytics Workspace: `log-day01-gov-weu`
- Subscription diagnostic setting: `diag-activitylogs-weu` → `log-day01-gov-weu`
- Custom Role: `Reader-Storage-Limited` (RG scope)

## KQL
```kql
AzureActivity
| where TimeGenerated > ago(24h)
| where tolower(OperationNameValue) has_any ("microsoft.authorization/roleassignments", "microsoft.resources/tags/write")
| project TimeGenerated, Category, OperationName, OperationNameValue, ResourceId, SubscriptionId, Caller, ActivityStatus
| order by TimeGenerated desc
Notes
Template only. No role assignment included.

Add role assignments later in a persistent tenant.
