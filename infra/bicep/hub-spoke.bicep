// Production-ready hub-spoke network topology
// Secure-by-default networking with explicit inbound controls

targetScope = 'resourceGroup'

@description('Location for resources')
param location string = 'westeurope'

@description('Hub virtual network name')
param hubVnetName string = 'vnet-hub-weu'

@description('Spoke virtual network name')
param spokeVnetName string = 'vnet-spoke-weu'

@description('Network security group for workloads subnet')
param workloadsNsgName string = 'nsg-spoke-workloads'

// Hub VNet with shared services and gateway-related subnets
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'shared-services'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

// NSG for workloads subnet: allow HTTPS only from the firewall subnet
resource workloadsNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: workloadsNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-Https-From-AzureFirewall'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '10.0.0.0/24'
          destinationAddressPrefix: '10.1.0.0/24'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// Public IP for Azure Firewall (standard, static)
resource firewallPublicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: 'pip-azfw-hub'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Azure Firewall in hub VNet with a single IP configuration
resource azureFirewall 'Microsoft.Network/azureFirewalls@2023-11-01' = {
  name: 'azfw-hub'
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: 'azfw-ipconfig'
        properties: {
          subnet: {
            id: hubVnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: firewallPublicIp.id
          }
        }
      }
    ]
  }
}

// Route table for spoke workloads subnet to force egress via Azure Firewall
resource workloadsRouteTable 'Microsoft.Network/routeTables@2023-11-01' = {
  name: 'rt-spoke-workloads'
  location: location
  properties: {
    routes: [
      {
        name: 'default-to-firewall'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: azureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

// Spoke VNet hosting workloads
resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: spokeVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'workloads'
        properties: {
          addressPrefix: '10.1.0.0/24'
          networkSecurityGroup: {
            id: workloadsNsg.id
          }
          routeTable: {
            id: workloadsRouteTable.id
          }
        }
      }
    ]
  }
}

// Hub-to-spoke peering with gateway transit enabled on hub
resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = {
  name: '${hubVnet.name}/peer-to-spoke'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spokeVnet.id
    }
  }
}

// Spoke-to-hub peering using remote gateways from hub
resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = {
  name: '${spokeVnet.name}/peer-to-hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
  }
}

@description('Hub VNet resource ID')
output hubVnetId string = hubVnet.id

@description('Spoke VNet resource ID')
output spokeVnetId string = spokeVnet.id

@description('Azure Firewall private IP address')
output firewallPrivateIp string = azureFirewall.properties.ipConfigurations[0].properties.privateIPAddress

@description('Azure Firewall public IP resource ID')
output firewallPublicIpId string = firewallPublicIp.id
/*
Codex expand task:
Enhance this hub-spoke design to be more production-ready by adding:

1) Azure Firewall (Microsoft.Network/azureFirewalls) in the hub VNet:
   - Add a public IP (Standard, Static) for the firewall
   - Configure at least one IP configuration referencing AzureFirewallSubnet

2) Route tables (UDR):
   - Create a route table for the spoke workloads subnet
   - Add a default route 0.0.0.0/0 next hop = VirtualAppliance, next hop IP = Azure Firewall private IP
   - Associate the route table to the spoke 'workloads' subnet

3) Keep secure-by-default:
   - Do NOT open inbound from Internet to workloads
   - Keep NSG rule allowing HTTPS only from AzureFirewallSubnet

Constraints:
- Keep targetScope = 'resourceGroup'
- Use same API versions already used in the file
- Add outputs: firewallPrivateIp, firewallPublicIpId
- Add short English comments
*/
