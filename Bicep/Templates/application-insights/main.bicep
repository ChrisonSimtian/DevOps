param applicationInsightsName string
param logAnalyticsWorkspaceName string

/* Common Settings Parameters */
@description('Resource Location')
param location string = resourceGroup().location

@description('Resource Tags')
@allowed(['CI', 'Devops', 'Prod', 'Regression', 'Test'])
param environment string

/* Common Settings */
module settings '../common/settings.bicep' = {
  name: 'settings'
  params: {
    location: location
    environment: environment
  }
}

module logAnalyticsWorkspace './modules/logAnalyticsWorkspace.bicep' = {
  name: 'logAnalyticsWorkspace'
  params: {
    name: logAnalyticsWorkspaceName
    location: settings.outputs.location
    tags: settings.outputs.tags
  }
}

module applicationInsights './modules/applicationInsights.bicep' = {
  name: 'applicationInsights'
  params: {
    location: settings.outputs.location
    tags: settings.outputs.tags
    name: applicationInsightsName
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.Name
  }
}
