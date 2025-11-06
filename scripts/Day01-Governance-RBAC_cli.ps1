#requires -Modules Az.Accounts, Az.Resources, Az.Monitor, Az.OperationalInsights
<#
Day01 – Governance & RBAC (PowerShell). Long-form parameters. Inline values.
Replace <ASSIGNEE_OBJECT_ID> with the target principal ObjectId.
#>

Subscription context

Set-AzContext -SubscriptionId "6fa98ff9-39fd-4547-9fd4-e27fb267d465"

Resource Group

New-AzResourceGroup -Name "rg-day01-governance-weu" -Location "westeurope" -Force | Out-Null
Set-AzResourceGroup -Name "rg-day01-governance-weu" -Tag @{ Environment="Dev"; Owner="Ehab.Saad"; Project="AZ-305"; CostCenter="GOV01" } | Out-Null

Log Analytics Workspace

New-AzOperationalInsightsWorkspace -ResourceGroupName "rg-day01-governance-weu"
-Name "log-day01-gov-weu" -Location "westeurope"
-Sku "PerGB2018" -PublicNetworkAccessForIngestion "Enabled"
-PublicNetworkAccessForQuery "Enabled" `
-Force | Out-Null

Export Activity Logs (subscription scope) → Workspace

Set-AzDiagnosticSetting -Name "diag-activitylogs-weu"
-Scope "/subscriptions/6fa98ff9-39fd-4547-9fd4-e27fb267d465" -WorkspaceId "/subscriptions/6fa98ff9-39fd-4547-9fd4-e27fb267d465/resourceGroups/rg-day01-governance-weu/providers/Microsoft.OperationalInsights/workspaces/log-day01-gov-weu"
-Enabled $true `
-Category "Administrative","Policy","Security","ServiceHealth","Alert","Recommendation" | Out-Null

Custom Role (RG scope)

$roleJson = @"
{
"Name": "Reader-Storage-Limited",
"IsCustom": true,
"Description": "Read-only access to Storage Accounts in rg-day01-governance-weu",
"Actions": [
"Microsoft.Storage/storageAccounts/read",
"Microsoft.Storage/storageAccounts/blobServices/containers/read"
],
"NotActions": [],
"DataActions": [],
"NotDataActions": [],
"AssignableScopes": [
"/subscriptions/6fa98ff9-39fd-4547-9fd4-e27fb267d465/resourceGroups/rg-day01-governance-weu"
]
}
"@

New-AzRoleDefinition -InputFile ([System.IO.Path]::GetTempFileName() | ForEach-Object {
Set-Content -Path $_ -Value $roleJson -Encoding UTF8; $_
}) | Out-Null

Role assignment (RG scope)

New-AzRoleAssignment -ObjectId "<ASSIGNEE_OBJECT_ID>"
-RoleDefinitionName "Reader-Storage-Limited" `
-Scope "/subscriptions/6fa98ff9-39fd-4547-9fd4-e27fb267d465/resourceGroups/rg-day01-governance-weu" | Out-Null

Optional: generate an admin log entry

New-AzTag -ResourceId "/subscriptions/6fa98ff9-39fd-4547-9fd4-e27fb267d465/resourceGroups/rg-day01-governance-weu" -Tag @{ TestLog = "VerifyActivityLog" } | Out-Null

Write-Host "Done. RG, workspace, diagnostics, custom role, role assignment."
