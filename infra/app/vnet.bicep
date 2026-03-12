@description('Specifies the name of the virtual network.')
param vNetName string

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the name of the subnet for the private endpoint.')
param peSubnetName string = 'private-endpoints-subnet'

@description('Specifies the name of the subnet for Function App virtual network integration.')
param appSubnetName string = 'app'

param tags object = {}

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.6.1' = {
  name: 'vnet-deployment'
  params: {
    name: vNetName
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    location: location
    tags: tags
    subnets: [
      {
        name: peSubnetName
        addressPrefix: '10.0.1.0/24'
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
      {
        name: appSubnetName
        addressPrefix: '10.0.2.0/24'
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        delegation: 'Microsoft.App/environments'
      }
    ]
  }
}

output peSubnetName string = peSubnetName
output peSubnetID string = '${virtualNetwork.outputs.resourceId}/subnets/${peSubnetName}'
output appSubnetName string = appSubnetName
output appSubnetID string = '${virtualNetwork.outputs.resourceId}/subnets/${appSubnetName}'
