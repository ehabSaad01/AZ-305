#!/bin/bash
# Day03 - Secure Network Design (AZ-305)
# This script creates a secure VNet with three subnets and corresponding NSGs.
# Each NSG applies Zero-Trust rules and sends diagnostics to Log Analytics.

# Variables (inline assignment)
RESOURCE_GROUP="rg-day01-governance-weu"
LOCATION="westeurope"
VNET_NAME="vnet-day03-secure-weu"
WORKSPACE="log-day01-gov-weu"

# 1. Create Virtual Network with subnets
az network vnet create \
  --name "$VNET_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --address-prefixes "10.0.0.0/16" \
  --subnet-name "Mgmt-Subnet" \
  --subnet-prefixes "10.0.1.0/24"

# 2. Add Frontend and Backend subnets
az network vnet subnet create \
  --name "Frontend-Subnet" \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$VNET_NAME" \
  --address-prefixes "10.0.2.0/24"

az network vnet subnet create \
  --name "Backend-Subnet" \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$VNET_NAME" \
  --address-prefixes "10.0.3.0/24"

# 3. Create NSGs
az network nsg create --resource-group "$RESOURCE_GROUP" --name "nsg-Frontend" --location "$LOCATION"
az network nsg create --resource-group "$RESOURCE_GROUP" --name "nsg-Backend" --location "$LOCATION"
az network nsg create --resource-group "$RESOURCE_GROUP" --name "nsg-Mgmt" --location "$LOCATION"

# 4. Create NSG rules
# Frontend NSG - Allow HTTP/HTTPS from Internet
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "nsg-Frontend" \
  --name "Allow-HTTP" \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes Internet \
  --source-port-ranges "*" \
  --destination-port-ranges 80

az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "nsg-Frontend" \
  --name "Allow-HTTPS" \
  --priority 110 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes Internet \
  --source-port-ranges "*" \
  --destination-port-ranges 443

# Backend NSG - Allow SQL only from Frontend subnet
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "nsg-Backend" \
  --name "Allow-Frontend-SQL" \
  --priority 200 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes "10.0.2.0/24" \
  --source-port-ranges "*" \
  --destination-port-ranges 1433

# Mgmt NSG - Allow Bastion (443)
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "nsg-Mgmt" \
  --name "Allow-Bastion" \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes AzureCloud \
  --source-port-ranges "*" \
  --destination-port-ranges 443
