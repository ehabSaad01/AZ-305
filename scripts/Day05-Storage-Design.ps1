<#
    Day 05 – Storage Design & Integration (PowerShell)
    - Create resource group
    - Create Storage Account (StorageV2, HTTPS-only, no anonymous access)
    - Create private container
    - Enable Boot Diagnostics on existing VM using this Storage Account
    - (Log Analytics diagnostic settings are covered mainly in the CLI script)
#>

param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -----------------------------
# Configuration (inline values)
# -----------------------------

# Resource group for storage
$ResourceGroupName = "rg-day05-storage"
$Location = "westeurope"

# Storage account
$StorageAccountName = "stday05labweu"
$StorageSkuName = "Standard_LRS"
$StorageKind = "StorageV2"
$StorageAccessTier = "Hot"

# Test container
$ContainerName = "logs-test"

# Existing VM from Day 04
$VmResourceGroupName = "rg-day04-compute"
$VmName = "vmday04ub"

# -----------------------------
# 1. Create resource group
# -----------------------------
# Creates the resource group for the Day 05 storage lab.

Write-Host "Creating resource group $ResourceGroupName in $Location..."
New-AzResourceGroup `
    -Name $ResourceGroupName `
    -Location $Location `
    -Force | Out-Null

# -----------------------------
# 2. Create Storage Account
# -----------------------------
# Creates a StorageV2 account with HTTPS-only enforced and no anonymous access.

Write-Host "Creating storage account $StorageAccountName..."
New-AzStorageAccount `
    -Name $StorageAccountName `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -SkuName $StorageSkuName `
    -Kind $StorageKind `
    -AccessTier $StorageAccessTier `
    -EnableHttpsTrafficOnly $true `
    -AllowBlobPublicAccess $false | Out-Null

# -----------------------------
# 3. Create private container
# -----------------------------
# Uses the connected account (Azure AD) instead of account keys.

Write-Host "Creating private container $ContainerName..."
$storageContext = New-AzStorageContext `
    -StorageAccountName $StorageAccountName `
    -UseConnectedAccount

New-AzStorageContainer `
    -Name $ContainerName `
    -Context $storageContext `
    -Permission Off | Out-Null

# -----------------------------
# 4. Enable Boot Diagnostics on existing VM
# -----------------------------
# Switches the VM boot diagnostics to use the custom storage account.

Write-Host "Enabling Boot Diagnostics on VM $VmName with storage account $StorageAccountName..."

# Get VM configuration
$vm = Get-AzVM -Name $VmName -ResourceGroupName $VmResourceGroupName

# Enable boot diagnostics with the custom storage account
$vm | Set-AzVMBootDiagnostic `
        -Enable `
        -ResourceGroupName $ResourceGroupName `
        -StorageAccountName $StorageAccountName | Out-Null

# Apply the VM configuration
$vm | Update-AzVM | Out-Null

Write-Host "Boot Diagnostics has been configured to use $StorageAccountName."
Write-Host "Day 05 – Storage Design & Integration (PowerShell) completed."
