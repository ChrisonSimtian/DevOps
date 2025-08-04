param name string = 'DefaultWorkspace-9f6bbd17-3dae-40c3-87c5-59ac961a8f72-EAU'
param location string
param tags object

resource logAnalyticsWorkspace_Resource 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      legacy: 0
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: json('-1')
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output Id string = logAnalyticsWorkspace_Resource.id
output Name string = logAnalyticsWorkspace_Resource.name
output ApiVersion string = logAnalyticsWorkspace_Resource.apiVersion
output ExternalId string = logAnalyticsWorkspace_Resource.properties.customerId
