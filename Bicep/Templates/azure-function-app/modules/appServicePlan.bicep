param name string
param canonicalLocation string
param tags object

resource serverfarms_ASP_mfberptest_a1ee_name_resource 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: name
  location: canonicalLocation
  tags: tags
  sku: {
    name: 'FC1'
    tier: 'FlexConsumption'
    size: 'FC1'
    family: 'FC'
    capacity: 0
  }
  kind: 'functionapp'
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

output Id string = serverfarms_ASP_mfberptest_a1ee_name_resource.id
output Name string = serverfarms_ASP_mfberptest_a1ee_name_resource.name
