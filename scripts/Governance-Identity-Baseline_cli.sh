#!/usr/bin/env bash
set -euo pipefail

# Governance & Identity Baseline — Day 01 (CLI, Bash)
# Notes:
# - Long options only. No external variables. Inline queries for IDs.
# - Secure-by-default: allowed region = West Europe, central logging, least privilege placeholders.

# 1) Create Management Group
az account management-group create \
  --name mg-hub-weu \
  --display-name "Hub - West Europe"

# 2) Attach current Subscription to that Management Group
az account management-group subscription add \
  --name mg-hub-weu \
  --subscription "$(az account show --query id --output tsv)"

# 3) Governance Resource Group in West Europe
az group create \
  --name rg-gov-weu \
  --location westeurope

# 4) Log Analytics Workspace (30-day retention)
az monitor log-analytics workspace create \
  --resource-group rg-gov-weu \
  --workspace-name law-gov-weu \
  --location westeurope \
  --sku PerGB2018 \
  --retention-time 30

# 5) User-Assigned Managed Identity
az identity create \
  --name uami-gov-weu \
  --resource-group rg-gov-weu \
  --location westeurope

# 6) Policy: Allowed locations = West Europe at MG scope
az policy assignment create \
  --name "deny-non-weu" \
  --display-name "Deny non West Europe locations" \
  --scope "/providers/Microsoft.Management/managementGroups/mg-hub-weu" \
  --policy "$(az policy definition list --query "[?displayName=='Allowed locations'].id | [0]" --output tsv)" \
  --params "{\"listOfAllowedLocations\": {\"value\": [\"westeurope\"]}}" \
  --enforcement-mode Default

# 7) Subscription Activity Logs → LAW (includes Policy)
az monitor diagnostic-settings subscription create \
  --name diag-activity-to-law \
  --workspace "$(az monitor log-analytics workspace show --resource-group rg-gov-weu --workspace-name law-gov-weu --query id --output tsv)" \
  --logs '[{"category":"Administrative","enabled":true},{"category":"Security","enabled":true},{"category":"ServiceHealth","enabled":true},{"category":"Alert","enabled":true},{"category":"Recommendation","enabled":true},{"category":"Policy","enabled":true},{"category":"Autoscale","enabled":true},{"category":"ResourceHealth","enabled":true}]'

# 8) RBAC example (placeholder). Replace <OBJECT_ID> to enable:
# az role assignment create \
#   --assignee-object-id "<OBJECT_ID>" \
#   --assignee-principal-type User \
#   --role "Reader" \
#   --scope "/subscriptions/$(az account show --query id --output tsv)/resourceGroups/rg-gov-weu"

echo "Governance & Identity Baseline — CLI completed."
