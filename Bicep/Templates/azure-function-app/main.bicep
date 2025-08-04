param functionAppName string
param appServicePlanName string
param appServicePlanSku object

param applicationInsightsName string
param storageAccountName string

/* Common Settings Parameters */
@description('Resource Location')
param location string = resourceGroup().location

@description('Resource Tags')
@allowed(['CI', 'Devops', 'Prod', 'Regression', 'Test'])
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
    location: settings.outputs.location
    tags: settings.outputs.tags
    name: appServicePlanName
    sku: appServicePlanSku
  }
}

module functionApp './modules/functionApp.bicep' = {
  name: 'functionApp'
  params: {
    location: settings.outputs.location
    tags: settings.outputs.tags
    name: functionAppName
    appServicePlanName: appServicePlan.outputs.Name
    storageAccountName: storageAccount_Resource.name
    applicationInsightsName: applicationInsights_Resource.name
  }
}
