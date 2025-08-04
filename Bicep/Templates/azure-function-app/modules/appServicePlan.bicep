param name string
param location string
param tags object
param sku object

resource appServicePlan_Resource 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: name
  location: location
  sku: sku
  kind: 'functionapp'
  tags: tags
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
    asyncScalingEnabled: false
  }
}

output Id string = appServicePlan_Resource.id
output Name string = appServicePlan_Resource.name
