# Day03 - Secure Network Design (AZ-305)
# This PowerShell script replicates the CLI operations for creating a secure VNet and NSGs.

$ResourceGroup = "rg-day01-governance-weu"
$Location = "westeurope"
$VNetName = "vnet-day03-secure-weu"

# 1. Create VNet and Subnets
New-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroup -Location $Location -AddressPrefix "10.0.0.0/16" | `
  Add-AzVirtualNetworkSubnetConfig -Name "Mgmt-Subnet" -AddressPrefix "10.0.1.0/24" | `
  Add-AzVirtualNetworkSubnetConfig -Name "Frontend-Subnet" -AddressPrefix "10.0.2.0/24" | `
  Add-AzVirtualNetworkSubnetConfig -Name "Backend-Subnet" -AddressPrefix "10.0.3.0/24" | `
  Set-AzVirtualNetwork

# 2. Create NSGs
New-AzNetworkSecurityGroup -Name "nsg-Frontend" -ResourceGroupName $ResourceGroup -Location $Location
New-AzNetworkSecurityGroup -Name "nsg-Backend" -ResourceGroupName $ResourceGroup -Location $Location
New-AzNetworkSecurityGroup -Name "nsg-Mgmt" -ResourceGroupName $ResourceGroup -Location $Location

# 3. Add Security Rules (examples)
$frontend = Get-AzNetworkSecurityGroup -Name "nsg-Frontend" -ResourceGroupName $ResourceGroup
$ruleHttp = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "Allow HTTP from Internet" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * -DestinationPortRange 80
$ruleHttps = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTPS" -Description "Allow HTTPS from Internet" -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 -SourceAddressPrefix Internet -SourcePortRange * -DestinationPortRange 443
$frontend.SecurityRules.Add($ruleHttp)
$frontend.SecurityRules.Add($ruleHttps)
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $frontend
