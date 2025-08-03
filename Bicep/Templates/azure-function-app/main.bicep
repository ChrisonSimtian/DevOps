param functionAppName string
param appServicePlanName string

param applicationInsightsName string
param storageAccountName string

param location string
param environment string

/* Reference existing Resources */
resource storageAccount_Resource 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: storageAccountName
}

resource applicationInsights_Resource 'microsoft.insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

/* Common Settings */
module settings '../common/settings.bicep' = {
  name: 'settings'
  params: {
    location: location
    environment: environment
  }
}

/* Spin up Resources */
module appServicePlan './modules/appServicePlan.bicep' = {
  name: 'appServicePlan'
  params: {
    canonicalLocation: settings.outputs.canonicalLocation
    tags: settings.outputs.tags
    name: appServicePlanName
  }
}

module functionApp './modules/functionApp.bicep' = {
  name: 'functionApp'
  params: {
    canonicalLocation: settings.outputs.canonicalLocation
    tags: settings.outputs.tags
    name: functionAppName
    appServicePlanName: appServicePlan.outputs.Name
    storageAccountName: storageAccount_Resource.name
    applicationInsightsName: applicationInsights_Resource.name
  }
}
