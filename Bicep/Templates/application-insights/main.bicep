param applicationInsightsName string
param logAnalyticsWorkspaceName string

param location string
param environment string

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
    canonicalLocation: settings.outputs.canonicalLocation
    tags: settings.outputs.tags
  }
}

module applicationInsights './modules/applicationInsights.bicep' = {
  name: 'applicationInsights'
  params: {
    canonicalLocation: settings.outputs.canonicalLocation
    tags: settings.outputs.tags
    name: applicationInsightsName
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.Name
  }
}
