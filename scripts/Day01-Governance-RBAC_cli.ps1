#requires -Modules Az.Accounts, Az.Resources, Az.Monitor, Az.OperationalInsights
<#
Day01 – Governance & RBAC (PowerShell).
Template build: no role assignment. Add later in a persistent tenant.
#>

Set-AzContext -SubscriptionId "6fa98ff9-39fd-4547-9fd4-e27fb267d465"

RG

New-AzResourceGroup -Name "rg-day01-governance-weu" -Location "westeurope" -Force | Out-Null
Set-AzResourceGroup -Name "rg-day01-governance-weu" -Tag @{ Environment="Dev"; Owner="Ehab.Saad"; Project="AZ-305"; CostCenter="GOV01" } | Out-Null

Log Analytics

New-AzOperationalInsightsWorkspace -ResourceGroupName "rg-day01-governance-weu"
-Name "log-day01-gov-weu" -Location "westeurope"
-Sku "PerGB2018" -PublicNetworkAccessForIngestion "Enabled"
-PublicNetworkAccessForQuery "Enabled" `
-Force | Out-Null

Export Activity Logs (subscription scope)

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

--- Role assignment intentionally omitted ---
Example to add later:
New-AzRoleAssignment `
-ObjectId "<OBJECT_ID>" `
-RoleDefinitionName "Reader-Storage-Limited" `
-Scope "/subscriptions/6fa98ff9-39fd-4547-9fd4-e27fb267d465/resourceGroups/rg-day01-governance-weu" | Out-Null

Write-Host "Template applied without role assignment."
