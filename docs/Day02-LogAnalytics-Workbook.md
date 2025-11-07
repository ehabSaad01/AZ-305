# Day 02 – Log Analytics & Workbooks

## Objectives
- Connect Resource Groups and Policies to Log Analytics Workspace.
- Enable Activity, Policy, and Security logs.
- Create KQL queries for AzureActivity analysis.
- Build a modern Workbook for operational compliance visualization.
- Validate log flow and save queries.

## Key Queries
```kusto
AzureActivity
| summarize Count = count() by ActivityStatusValue

Workbook Created

Name: Operational-Compliance-Overview
Location: West Europe
Category: Workbook
Visualization: Pie + Bar
Export: Operational-Compliance-Overview.workbook.json

Verification

Logs received successfully (latest record: Microsoft.Storage/ListKeys).

Workbook shared via RBAC link.

Saved query created under Azure Monitor category.

