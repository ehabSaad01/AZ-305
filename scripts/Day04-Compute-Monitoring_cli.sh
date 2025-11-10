#!/bin/bash
# Day04 - Compute & Monitoring (AZ-305)
# This script deploys a VM without public IP and enables diagnostics to Log Analytics.

RESOURCE_GROUP="rg-day01-governance-weu"
LOCATION="westeurope"
VNET_NAME="vnet-day03-secure-weu"
SUBNET_NAME="Frontend-Subnet"
VM_NAME="vm-day04-ubuntu-weu"
WORKSPACE="log-day01-gov-weu"

# 1. Create VM
az vm create \
  --name "$VM_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --image "Ubuntu2204" \
  --size "Standard_B1s" \
  --admin-username "azureuser" \
  --authentication-type "password" \
  --generate-ssh-keys false \
  --public-ip-address "" \
  --vnet-name "$VNET_NAME" \
  --subnet "$SUBNET_NAME" \
  --nsg "" \
  --no-wait

# 2. Enable diagnostic settings (AllMetrics)
az monitor diagnostic-settings create \
  --name "diag-vm-day04" \
  --resource "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/$VM_NAME" \
  --workspace "$WORKSPACE" \
  --metrics '[{"category": "AllMetrics","enabled": true}]'
