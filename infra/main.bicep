targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name which is used to generate a short unique hash for each resource')
param name string

@minLength(1)
@description('Primary location for all resources')
param location string

var resourceToken = toLower(uniqueString(subscription().id, name, location))
var tags = { 'azd-env-name': name }

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${name}-rg'
  location: location
  tags: tags
}

var prefix = '${name}-${resourceToken}'
var appInsightsName = '${prefix}-appinsights'
var appServicePlanName = '${prefix}-plan'

module monitoring './core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    logAnalyticsName: '${prefix}-logworkspace'
    applicationInsightsName: appInsightsName
    applicationInsightsDashboardName: '${prefix}-appinsights-dashboard'
  }
}

module storageAccount 'core/storage/storage-account.bicep' = {
  name: 'storage'
  scope: resourceGroup
  params: {
    name: '${toLower(take(replace(prefix, '-', ''), 17))}storage'
    location: location
    tags: tags
  }
}

module appServicePlan './core/host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  scope: resourceGroup
  params: {
    name: appServicePlanName
    location: location
    tags: tags
    sku: {
      name: 'Y1'
      tier: 'Dynamic'
    }
  }
}

module functionApp 'core/host/functions.bicep' = {
  name: 'function'
  scope: resourceGroup
  params: {
    name: '${prefix}-function-app'
    location: location
    tags: union(tags, { 'azd-service-name': 'api' })
    alwaysOn: false
    appSettings: {
      PYTHON_ISOLATE_WORKER_DEPENDENCIES: 1
    }
    applicationInsightsName: appInsightsName
    appServicePlanId: appServicePlan.outputs.id
    runtimeName: 'python'
    runtimeVersion: '3.9'
    storageAccountName: storageAccount.outputs.name
  }
}
