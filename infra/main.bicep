targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param name string

@minLength(1)
@description('Primary location for all resources')
param location string

param resourceGroupName string = ''

// Optional parameters
param tags object = {}

// Variables
var prefix = '${name}-${uniqueString(name)}'
var resourceGroupName_var = resourceGroupName == '' ? 'rg-${name}' : resourceGroupName
var tags_var = union(tags, { 'azd-env-name': name })

// Create a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName_var
  location: location
  tags: tags_var
}

// Monitor application with Azure Monitor
module monitoring 'core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  scope: resourceGroup
  params: {
    location: location
    tags: tags_var
    logAnalyticsName: '${prefix}-logworkspace'
    applicationInsightsName: '${prefix}-appinsights'
    applicationInsightsDashboardName: '${prefix}-appinsights-dashboard'
  }
}

// Storage for hosting static website
module storage 'core/storage/storage-account.bicep' = {
  name: 'storage'
  scope: resourceGroup
  params: {
    name: '${toLower(take(replace(prefix, '-', ''), 17))}storage'
    location: location
    tags: tags_var
  }
}

// App Service Plan
module appserviceplan 'core/host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  scope: resourceGroup
  params: {
    name: '${prefix}-plan'
    location: location
    tags: tags_var
    sku: {
      name: 'Y1'
      tier: 'Dynamic'
      size: 'Y1'
      family: 'Y'
      capacity: 0
    }
  }
}

// Azure Functions
module function 'core/host/functions.bicep' = {
  name: 'function'
  scope: resourceGroup
  params: {
    name: '${prefix}-function-app'
    location: location
    tags: union(tags_var, { 'azd-service-name': 'api' })
    alwaysOn: false
    appSettings: {
      AzureWebJobsFeatureFlags: 'EnableWorkerIndexing'
    }
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    appServicePlanId: appserviceplan.outputs.id
    runtimeName: 'python'
    runtimeVersion: '3.10'
    storageAccountName: storage.outputs.name
    skipRoleAssignment: true  // Add this to prevent role assignment errors
  }
}

// Function app diagnostics
module functionDiagnostics 'core/host/app-diagnostics.bicep' = {
  name: '${name}-functions-diagnostics'
  scope: resourceGroup
  params: {
    appName: function.outputs.name
    kind: 'functionapp'
    diagnosticWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
  }
  dependsOn: [
    function
    monitoring
  ]
}

// Output
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output RESOURCE_GROUP_ID string = resourceGroup.id
output functionAppName string = function.outputs.name
output functionAppEndpoint string = function.outputs.uri
