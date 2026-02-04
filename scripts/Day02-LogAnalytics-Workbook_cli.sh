#!/usr/bin/env bash
set -euo pipefail

# --- Purpose ------------------------------------------------------------
# Day 02 CLI Runbook: Validate AzureActivity logs, export Workbook JSON,
# and push docs to GitHub. Long options only. No shell variables.
# -----------------------------------------------------------------------

# 1) Verify Azure account context
az account show --output table

# 2) Run a KQL against AzureActivity for the last 15 minutes
az monitor log-analytics query \
  --workspace "$(az monitor log-analytics workspace list --resource-group rg-day01-governance-weu --query '[0].customerId' --output tsv)" \
  --analytics-query "AzureActivity | where TimeGenerated > ago(15m) | summarize Count = count() by ActivityStatusValue | order by ActivityStatusValue asc" \
  --out table

# 3) Export the existing Workbook JSON definition
az resource show \
  --resource-group rg-day01-governance-weu \
  --resource-type "microsoft.insights/workbooks" \
  --name "4216c21e-8653-41fd-9654-3469a25bd023" \
  --output json > "$HOME/AZ-305/docs/workbooks/Operational-Compliance-Overview.workbook.json"

# 4) Ensure Day02 doc exists and append a verification line
mkdir -p "$HOME/AZ-305/docs" "$HOME/AZ-305/docs/workbooks"
if [ ! -f "$HOME/AZ-305/docs/Day02-LogAnalytics-Workbook.md" ]; then
  cat << 'MD' > "$HOME/AZ-305/docs/Day02-LogAnalytics-Workbook.md"
# Day 02 – Log Analytics & Workbooks
This file documents KQL, Workbook creation, sharing (RBAC), and export steps.
MD
fi
echo "- Exported workbook JSON on $(date -u +"%Y-%m-%dT%H:%M:%SZ")." >> "$HOME/AZ-305/docs/Day02-LogAnalytics-Workbook.md"

# 5) Git add/commit/push the new artifacts
cd "$HOME/AZ-305"
git add "scripts/Day02-LogAnalytics-Workbook_cli.sh" "docs/Day02-LogAnalytics-Workbook.md" "docs/workbooks/Operational-Compliance-Overview.workbook.json"
git commit --message "Day02: Add CLI runbook and exported Workbook JSON"
git push origin main
