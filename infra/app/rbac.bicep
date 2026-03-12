param storageAccountName string
param appInsightsName string
param managedIdentityPrincipalId string
param userIdentityPrincipalId string = ''
param allowUserIdentityPrincipal bool = false
param enableBlob bool = true
param enableQueue bool = false
param enableTable bool = false

var storageRoleDefinitionId  = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
var queueRoleDefinitionId = '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
var tableRoleDefinitionId = '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
var monitoringRoleDefinitionId = '3913510d-42f4-4e42-8a64-420c390055eb'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableBlob) {
  name: guid(storageAccount.id, managedIdentityPrincipalId, storageRoleDefinitionId)
  scope: storageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageRoleDefinitionId)
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource storageRoleAssignment_User 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableBlob && allowUserIdentityPrincipal && !empty(userIdentityPrincipalId)) {
  name: guid(storageAccount.id, userIdentityPrincipalId, storageRoleDefinitionId)
  scope: storageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageRoleDefinitionId)
    principalId: userIdentityPrincipalId
    principalType: 'User'
  }
}

resource queueRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableQueue) {
  name: guid(storageAccount.id, managedIdentityPrincipalId, queueRoleDefinitionId)
  scope: storageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', queueRoleDefinitionId)
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource queueRoleAssignment_User 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableQueue && allowUserIdentityPrincipal && !empty(userIdentityPrincipalId)) {
  name: guid(storageAccount.id, userIdentityPrincipalId, queueRoleDefinitionId)
  scope: storageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', queueRoleDefinitionId)
    principalId: userIdentityPrincipalId
    principalType: 'User'
  }
}

resource tableRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableTable) {
  name: guid(storageAccount.id, managedIdentityPrincipalId, tableRoleDefinitionId)
  scope: storageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', tableRoleDefinitionId)
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource tableRoleAssignment_User 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableTable && allowUserIdentityPrincipal && !empty(userIdentityPrincipalId)) {
  name: guid(storageAccount.id, userIdentityPrincipalId, tableRoleDefinitionId)
  scope: storageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', tableRoleDefinitionId)
    principalId: userIdentityPrincipalId
    principalType: 'User'
  }
}

resource appInsightsRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(applicationInsights.id, managedIdentityPrincipalId, monitoringRoleDefinitionId)
  scope: applicationInsights
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', monitoringRoleDefinitionId)
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource appInsightsRoleAssignment_User 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (allowUserIdentityPrincipal && !empty(userIdentityPrincipalId)) {
  name: guid(applicationInsights.id, userIdentityPrincipalId, monitoringRoleDefinitionId)
  scope: applicationInsights
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', monitoringRoleDefinitionId)
    principalId: userIdentityPrincipalId
    principalType: 'User'
  }
}
