# --- Purpose ------------------------------------------------------------
# Day 02 PowerShell Runbook: Validate AzureActivity logs, export Workbook JSON,
# and push docs to GitHub. Long-form cmdlets only. No variables used.
# -----------------------------------------------------------------------
# 1) Verify Azure account context
#    Shows current context to ensure the correct subscription is active.
Get-AzContext | Format-List

# 2) Run a KQL against AzureActivity for the last 15 minutes
#    Resolves the first workspace in the RG inline without assigning variables.
(Get-AzOperationalInsightsWorkspace -ResourceGroupName "rg-day01-governance-weu" | Select-Object -First 1 | ForEach-Object {
    Invoke-AzOperationalInsightsQuery -WorkspaceId $_.CustomerId -Query @"
AzureActivity
| where TimeGenerated > ago(15m)
| summarize Count = count() by ActivityStatusValue
| order by ActivityStatusValue asc
"@
}) | Format-Table -AutoSize

# 3) Export the existing Workbook JSON definition
#    Reads the workbook resource and writes JSON to docs/workbooks.
(Get-AzResource -ResourceGroupName "rg-day01-governance-weu" -ResourceType "microsoft.insights/workbooks" -Name "4216c21e-8653-41fd-9654-3469a25bd023" | ConvertTo-Json -Depth 100) `
| Out-File -FilePath "$HOME/AZ-305/docs/workbooks/Operational-Compliance-Overview.workbook.json" -Encoding UTF8

# 4) Ensure Day02 doc exists and append a verification line
#    Keeps documentation cohesive and reproducible.
New-Item -ItemType Directory -Path "$HOME/AZ-305/docs/workbooks" -Force | Out-Null
New-Item -ItemType Directory -Path "$HOME/AZ-305/docs" -Force | Out-Null
if (-not (Test-Path "$HOME/AZ-305/docs/Day02-LogAnalytics-Workbook.md")) {
    @"
# Day 02 – Log Analytics & Workbooks
This file documents KQL, Workbook creation, sharing (RBAC), and export steps.
"@ | Out-File -FilePath "$HOME/AZ-305/docs/Day02-LogAnalytics-Workbook.md" -Encoding UTF8
}
("- Exported workbook JSON on {0}." -f ([DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ"))) `
| Out-File -FilePath "$HOME/AZ-305/docs/Day02-LogAnalytics-Workbook.md" -Append -Encoding UTF8

# 5) Git add/commit/push the new artifacts
#    Commits only the updated Day02 doc and workbook JSON.
Set-Location -Path "$HOME/AZ-305"
git add "scripts/Day02-LogAnalytics-Workbook.ps1" "docs/Day02-LogAnalytics-Workbook.md" "docs/workbooks/Operational-Compliance-Overview.workbook.json"
git commit -m "Day02: Add PowerShell runbook and exported Workbook JSON"
git push origin main
