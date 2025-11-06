#!/usr/bin/env bash

Day01 – Governance & RBAC (Azure CLI). Long options only. Inline values.
Template build: no role assignment. Add later in a persistent tenant.

set -euo pipefail

Subscription context

az account set --subscription "6fa98ff9-39fd-4547-9fd4-e27fb267d465" --only-show-errors

RG

az group create
--name "rg-day01-governance-weu"
--location "westeurope"
--only-show-errors --output table
az group update
--name "rg-day01-governance-weu"
--set "tags.Environment=Dev" "tags.Owner=Ehab.Saad" "tags.Project=AZ-305" "tags.CostCenter=GOV01"
--only-show-errors --output table

Log Analytics

az monitor log-analytics workspace create
--resource-group "rg-day01-governance-weu"
--workspace-name "log-day01-gov-weu"
--location "westeurope"
--sku "PerGB2018"
--only-show-errors --output table

Export Activity Logs (subscription scope)

az monitor diagnostic-settings create
--name "diag-activitylogs-weu"
--resource "/subscriptions/6fa98ff9-39fd-4547-9fd4-e27fb267d465"
--workspace "/subscriptions/6fa98ff9-39fd-4547-9fd4-e27fb267d465/resourceGroups/rg-day01-governance-weu/providers/Microsoft.OperationalInsights/workspaces/log-day01-gov-weu"
--logs '[
{"category": "Administrative", "enabled": true},
{"category": "Policy", "enabled": true},
{"category": "Security", "enabled": true},
{"category": "ServiceHealth", "enabled": true},
{"category": "Alert", "enabled": true},
{"category": "Recommendation", "enabled": true}
]'
--only-show-errors --output table

Custom Role (RG scope)

az role definition create
--role-definition '{
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
}'
--only-show-errors

--- Role assignment intentionally omitted ---
Example to add later:
az role assignment create \
--assignee-object-id "<OBJECT_ID>" \
--assignee-principal-type "User" \
--role "Reader-Storage-Limited" \
--scope "/subscriptions/6fa98ff9-39fd-4547-9fd4-e27fb267d465/resourceGroups/rg-day01-governance-weu" \
--only-show-errors --output table

echo "Template applied without role assignment."
