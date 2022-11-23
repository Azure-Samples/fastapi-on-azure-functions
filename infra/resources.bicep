param name string
param location string = resourceGroup().location
param resourceToken string
param tags object

var prefix = '${name}-${resourceToken}'

var appServicePlanName = '${prefix}-plan'


resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${prefix}-logworkspace'
  location: location
  tags: tags
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: '${prefix}-appinsights'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

var validStoragePrefix = toLower(take(replace(prefix, '-', ''), 17))

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: '${validStoragePrefix}storage'
  location: location
  kind: 'StorageV2'
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2020-10-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  kind: 'functionapp'
  properties: {
    reserved: true
  }
  sku: {
    name: 'Y1'
  }
}

resource functionApp 'Microsoft.Web/sites@2020-06-01' = {
  name: '${prefix}-function-app'
  location: location
  tags: union(tags, {
    'azd-service-name': 'api'
   })
  kind: 'functionapp,linux'
  properties: {
    httpsOnly: true
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: false
    siteConfig: {
      linuxFxVersion: 'Python|3.9'
      appSettings: [
        {
           name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
           value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'ENABLE_ORYX_BUILD'
          value: 'true'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
        {
          name: 'PYTHON_ISOLATE_WORKER_DEPENDENCIES'
          value: '1'
        }
      ]
    }
  }
}

module appInsightsDashboard 'appinsightsdashboard.bicep' = {
  name: 'appinsights-dashboard'
  params: {
    prefix: prefix
    location: location
    tags: tags
    appInsightsName: appInsights.name
  }
}