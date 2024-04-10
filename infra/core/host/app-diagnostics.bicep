param appName string = ''

@description('The kind of the app.')
@allowed([
  'functionapp'
  'webapp'
])
param kind string

@description('Resource ID of log analytics workspace.')
param diagnosticWorkspaceId string

param diagnosticLogCategoriesToEnable array = kind == 'functionapp' ? [
  'FunctionAppLogs'
] : [
  'AppServiceHTTPLogs'
  'AppServiceConsoleLogs'
  'AppServiceAppLogs'
  'AppServiceAuditLogs'
  'AppServiceIPSecAuditLogs'
  'AppServicePlatformLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]


var diagnosticsLogs = [for category in diagnosticLogCategoriesToEnable: {
  category: category
  enabled: true
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

resource app 'Microsoft.Web/sites@2022-03-01' existing = {
  name: appName
}

resource app_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${appName}-diagnostics'
  scope: app
  properties: {
    workspaceId:  diagnosticWorkspaceId 
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
  }
}
