# Governance & Identity Baseline — Day 01

## Objectives
- Establish tenant-level governance using **Management Groups**.
- Enforce region control with **Allowed locations** policy (West Europe).
- Implement **RBAC** on least privilege principles.
- Centralize logs with **Log Analytics Workspace** and export **Subscription Activity Logs**.

## Runbook — Portal → CLI → PowerShell
1. Use Portal for initial setup and validation.
2. Reproduce the same via **Bash CLI** or **PowerShell** scripts for automation.
3. Commit scripts and docs to GitHub for traceability.

## How to execute
### Bash (Azure CLI)
```bash
chmod +x ./scripts/Governance-Identity-Baseline_cli.sh
./scripts/Governance-Identity-Baseline_cli.sh
PowerShell
powershell
Copy code
pwsh ./scripts/Governance-Identity-Baseline_cli.ps1
Quick KQL checks (after logs start flowing)
kql
Copy code
AzureActivity
| where TimeGenerated > ago(24h)
| summarize TotalEvents = count()
kql
Copy code
AzureActivity
| where TimeGenerated > ago(24h)
| summarize Events=count() by Category
| order by Events desc
kql
Copy code
AzureActivity
| where TimeGenerated > ago(6h)
| where ActivityStatus == "Failed" or Category == "Policy"
| project TimeGenerated, Category, OperationName, ActivityStatus, ActivitySubstatus, ResourceGroup, Resource, ResourceProvider, Caller
| order by TimeGenerated desc
Note: Policy denials may appear under Administrative with ActivitySubstatus = Denied.

Security notes
RBAC first. Avoid broad roles.

Prefer Managed Identity over keys and secrets.

Restrict regions to reduce compliance risk and sprawl.

Next
Entra ID hardening and PIM (Day 02).

Saved Queries and Workbooks for continuous monitoring.
