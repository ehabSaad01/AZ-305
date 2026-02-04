#!/usr/bin/env bash

# Day 05 – Storage Design & Integration (Azure CLI)
# This script creates a Storage Account, a private container,
# configures diagnostic settings to send Transaction logs to a Log Analytics workspace,
# and enables Boot Diagnostics on an existing VM using this Storage Account.

set -euo pipefail

# -----------------------------
# Configuration (inline values)
# -----------------------------

# Resource group for storage
RESOURCE_GROUP="rg-day05-storage"
LOCATION="westeurope"

# Storage account
STORAGE_ACCOUNT_NAME="stday05labweu"
STORAGE_SKU="Standard_LRS"
STORAGE_KIND="StorageV2"
STORAGE_ACCESS_TIER="Hot"

# Test container
CONTAINER_NAME="logs-test"

# Existing VM from Day 04
VM_RESOURCE_GROUP="rg-day04-compute"
VM_NAME="vmday04ub"

# Log Analytics workspace (replace with your real workspace resource ID)
# Example format:
# /subscriptions/<SUB-ID>/resourceGroups/<RG-NAME>/providers/Microsoft.OperationalInsights/workspaces/<WORKSPACE-NAME>
WORKSPACE_ID="/subscriptions/<SUBSCRIPTION-ID>/resourceGroups/rg-day02-observability/providers/Microsoft.OperationalInsights/workspaces/log-day02-core-weu"

# Diagnostic setting name
DIAG_NAME="diag-storage-day05"

# -----------------------------
# 1. Create resource group
# -----------------------------
# Creates the resource group for the Day 05 storage lab.

az group create \
  --name "${RESOURCE_GROUP}" \
  --location "${LOCATION}" \
  --output json

# -----------------------------
# 2. Create Storage Account
# -----------------------------
# Creates a secure StorageV2 account with HTTPS-only and no anonymous access.

az storage account create \
  --name "${STORAGE_ACCOUNT_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --location "${LOCATION}" \
  --sku "${STORAGE_SKU}" \
  --kind "${STORAGE_KIND}" \
  --access-tier "${STORAGE_ACCESS_TIER}" \
  --https-only true \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2 \
  --output json

# -----------------------------
# 3. Create private container
# -----------------------------
# Uses Azure AD (RBAC) authentication instead of account keys.

az storage container create \
  --name "${CONTAINER_NAME}" \
  --account-name "${STORAGE_ACCOUNT_NAME}" \
  --auth-mode login \
  --public-access off \
  --output json

# -----------------------------
# 4. Configure Diagnostic Settings to Log Analytics
# -----------------------------
# Routes Transaction logs from the storage account to the given workspace.

STORAGE_RESOURCE_ID="$(az storage account show \
  --name "${STORAGE_ACCOUNT_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --query "id" \
  --output tsv)"

az monitor diagnostic-settings create \
  --name "${DIAG_NAME}" \
  --resource "${STORAGE_RESOURCE_ID}" \
  --workspace "${WORKSPACE_ID}" \
  --logs '[{"category":"Transaction","enabled":true,"retentionPolicy":{"enabled":false,"days":0}}]' \
  --output json

# -----------------------------
# 5. Enable Boot Diagnostics on existing VM
# -----------------------------
# Uses the custom storage account instead of the default managed storage.

az vm boot-diagnostics enable \
  --resource-group "${VM_RESOURCE_GROUP}" \
  --name "${VM_NAME}" \
  --storage "${STORAGE_ACCOUNT_NAME}" \
  --output json

# Optional: restart VM to force new boot diagnostic data
az vm restart \
  --resource-group "${VM_RESOURCE_GROUP}" \
  --name "${VM_NAME}" \
  --no-wait

echo "Day 05 – Storage Design & Integration (CLI) completed."
echo "Remember to verify boot diagnostics blobs in the storage account and KQL logs in Log Analytics."
