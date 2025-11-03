#!/usr/bin/env pwsh
# Governance & Identity Baseline — Day 01 (PowerShell)
# Requires Az modules loaded in Cloud Shell

$ErrorActionPreference = "Stop"

# 1) Create Management Group
# If it exists, New-AzManagementGroup will throw. Use try/catch to ignore duplicates.
try {
    New-AzManagementGroup -GroupName "mg-hub-weu" -DisplayName "Hub - West Europe" | Out-Null
} catch { }

# 2) Attach current Subscription to that Management Group
$subId = (Get-AzContext).Subscription.Id
New-AzManagementGroupSubscription -GroupName "mg-hub-weu" -SubscriptionId $subId -ErrorAction SilentlyContinue | Out-Null

# 3) Governance Resource Group
New-AzResourceGroup -Name "rg-gov-weu" -Location "westeurope" -Force | Out-Null

# 4) Log Analytics Workspace (30-day retention)
$law = New-AzOperationalInsightsWorkspace -ResourceGroupName "rg-gov-weu" -Name "law-gov-weu" -Location "westeurope" -Sku "PerGB2018" -RetentionInDays 30 -Force

# 5) User-Assigned Managed Identity
New-AzUserAssignedIdentity -Name "uami-gov-weu" -ResourceGroupName "rg-gov-weu" -Location "westeurope" | Out-Null

# 6) Policy: Allowed locations = West Europe at MG scope
$policy = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -eq "Allowed locations" } | Select-Object -First 1
$mgScope = "/providers/Microsoft.Management/managementGroups/mg-hub-weu"
New-AzPolicyAssignment -Name "deny-non-weu" `
  -DisplayName "Deny non West Europe locations" `
  -Scope $mgScope `
  -PolicyDefinition $policy `
  -PolicyParameterObject @{ listOfAllowedLocations = @{ value = @("westeurope") } } `
  -EnforcementMode Default | Out-Null

# 7) Subscription Activity Logs → LAW (includes Policy)
# Set-AzDiagnosticSetting at subscription scope
Set-AzDiagnosticSetting `
  -Name "diag-activity-to-law" `
  -SubscriptionId $subId `
  -WorkspaceId $law.ResourceId `
  -Category @("Administrative","Security","ServiceHealth","Alert","Recommendation","Policy","Autoscale","ResourceHealth") `
  -Enabled $true | Out-Null

Write-Output "Governance & Identity Baseline — PowerShell completed."
