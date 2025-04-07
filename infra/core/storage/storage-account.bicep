param name string
param location string = resourceGroup().location
param tags object = {}

@allowed([
  'Hot'
  'Cool'
  'Premium'
])
param accessTier string = 'Hot'
param allowBlobPublicAccess bool = false
param allowCrossTenantReplication bool = true
param allowSharedKeyAccess bool = true // This should be true to allow key-based access
param containers array = []
param defaultToOAuthAuthentication bool = false
param kind string = 'StorageV2'
param minimumTlsVersion string = 'TLS1_2'
param sku object = { name: 'Standard_LRS' }

resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  sku: sku
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    allowSharedKeyAccess: allowSharedKeyAccess // Explicitly use parameter value
    defaultToOAuthAuthentication: defaultToOAuthAuthentication // Explicitly use parameter value
    minimumTlsVersion: minimumTlsVersion
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = if (!empty(containers)) {
  parent: storage
  name: 'default'
  properties: {}
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = [for container in containers: {
  parent: blobServices
  name: container.name
  properties: {
    publicAccess: contains(container, 'publicAccess') ? container.publicAccess : 'None'
  }
}]

output name string = storage.name
output primaryEndpoints object = storage.properties.primaryEndpoints
