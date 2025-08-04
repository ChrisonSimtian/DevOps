param name string
param location string
param tags object
param logAnalyticsWorkspaceName string

resource logAnalyticsWorkspace_Resource 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource components_mfb_erp_func_ae_test_name_resource 'microsoft.insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaWebAppExtensionCreate'
    RetentionInDays: 90
    WorkspaceResourceId: logAnalyticsWorkspace_Resource.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    DisableLocalAuth: false
  }
}

output Id string = components_mfb_erp_func_ae_test_name_resource.id
output Name string = components_mfb_erp_func_ae_test_name_resource.name
output InstrumentationKey string = components_mfb_erp_func_ae_test_name_resource.properties.InstrumentationKey
output ConnectionString string = components_mfb_erp_func_ae_test_name_resource.properties.ConnectionString
