metadata description = 'Creates an Azure Function in an existing Azure App Service plan.'
param name string
param location string = resourceGroup().location
param tags object = {}

// Reference Properties
param applicationInsightsName string = ''
param appServicePlanId string
param keyVaultName string = ''
param managedIdentity bool = true // Always enable managed identity
param storageAccountName string

// Runtime Properties
@allowed([
  'dotnet', 'dotnetcore', 'dotnet-isolated', 'node', 'python', 'java', 'powershell', 'custom'
])
param runtimeName string
param runtimeNameAndVersion string = '${runtimeName}|${runtimeVersion}'
param runtimeVersion string

// Function Settings
@allowed([
  '~4', '~3', '~2', '~1'
])
param extensionVersion string = '~4'

// Microsoft.Web/sites Properties
param kind string = 'functionapp,linux'

// Microsoft.Web/sites/config
param allowedOrigins array = []
param alwaysOn bool = true
param appCommandLine string = ''
@secure()
param appSettings object = {}
param clientAffinityEnabled bool = false
param enableOryxBuild bool = contains(kind, 'linux')
param functionAppScaleLimit int = -1
param linuxFxVersion string = runtimeNameAndVersion
param minimumElasticInstanceCount int = -1
param numberOfWorkers int = -1
param scmDoBuildDuringDeployment bool = true
param use32BitWorkerProcess bool = false
param healthCheckPath string = ''

// Flag to skip role assignment - useful when role already exists
param skipRoleAssignment bool = false

module functions 'appservice.bicep' = {
  name: '${name}-functions'
  params: {
    name: name
    location: location
    tags: union(tags, {
      'azd-service-name': 'api'
    })
    allowedOrigins: allowedOrigins
    alwaysOn: alwaysOn
    appCommandLine: appCommandLine
    applicationInsightsName: applicationInsightsName
    appServicePlanId: appServicePlanId
    appSettings: union(appSettings, {
        AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${storage.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}' // Keep connection string as fallback
        AzureWebJobsStorage__accountName: storage.name // Add managed identity configuration
        FUNCTIONS_EXTENSION_VERSION: extensionVersion
        FUNCTIONS_WORKER_RUNTIME: 'python'
        PYTHON_ENABLE_WORKER_EXTENSIONS: '1'
        PYTHON_ISOLATE_WORKER_DEPENDENCIES: '1'
        ENABLE_ORYX_BUILD: 'true'
        SCM_DO_BUILD_DURING_DEPLOYMENT: 'true'
        PYTHON_VERSION: '3.10' // Updated to match main.bicep
        PYTHON_ENABLE_GUNICORN_MULTIWORKERS: '0'
        WEBSITE_HTTPLOGGING_RETENTION_DAYS: '7'
      })
    clientAffinityEnabled: clientAffinityEnabled
    enableOryxBuild: enableOryxBuild
    functionAppScaleLimit: functionAppScaleLimit
    healthCheckPath: healthCheckPath
    keyVaultName: keyVaultName
    kind: kind
    linuxFxVersion: linuxFxVersion
    managedIdentity: managedIdentity
    minimumElasticInstanceCount: minimumElasticInstanceCount
    numberOfWorkers: numberOfWorkers
    runtimeName: runtimeName
    runtimeVersion: runtimeVersion
    runtimeNameAndVersion: runtimeNameAndVersion
    scmDoBuildDuringDeployment: scmDoBuildDuringDeployment
    use32BitWorkerProcess: use32BitWorkerProcess
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName
}

// Define role names symbolically using well-known Azure built-in role names
// This encapsulates the knowledge of role definitions IDs in a single file
// These can be moved to a separate module if used across multiple files
var builtInRoleNames = {
  Owner: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  'User Access Administrator': '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
  'Storage Blob Data Contributor': 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  'Storage Blob Data Owner': 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
  'Storage Blob Data Reader': '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
}

// Skip role assignment if the flag is set
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!skipRoleAssignment) {
  name: guid(resourceGroup().id, name, builtInRoleNames['Storage Blob Data Contributor'])
  scope: storage
  properties: {
    principalId: functions.outputs.identityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', builtInRoleNames['Storage Blob Data Contributor'])
    principalType: 'ServicePrincipal'
  }
}

output identityPrincipalId string = functions.outputs.identityPrincipalId
output name string = functions.outputs.name
output uri string = functions.outputs.uri
