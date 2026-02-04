# Day04 - Compute & Monitoring (AZ-305)
# Deploy a Linux VM without Public IP and enable diagnostics to Log Analytics.

$ResourceGroup = "rg-day01-governance-weu"
$Location = "westeurope"
$VNet = "vnet-day03-secure-weu"
$Subnet = "Frontend-Subnet"
$VMName = "vm-day04-ubuntu-weu"
$Workspace = "log-day01-gov-weu"

# 1. Create VM
New-AzVM `
  -ResourceGroupName $ResourceGroup `
  -Name $VMName `
  -Location $Location `
  -VirtualNetworkName $VNet `
  -SubnetName $Subnet `
  -Image "Ubuntu2204" `
  -Size "Standard_B1s" `
  -PublicIpAddressName "" `
  -Credential (Get-Credential) `
  -AssignIdentity:$true

# 2. Configure Diagnostic Settings (AllMetrics)
$vm = Get-AzVM -Name $VMName -ResourceGroupName $ResourceGroup
Set-AzDiagnosticSetting -Name "diag-vm-day04" -ResourceId $vm.Id -WorkspaceId $Workspace -Enabled $true
