@description('Location for the resources. Defaults to Resource Group location.')
param location string = resourceGroup().location

@description('Environment')
@allowed(['CI', 'Devops', 'Prod', 'Regression', 'Test'])
param environment string

var locationMap = {
  /* relevant Azure regions */
  'Australia Southeast': 'australiasoutheast'
  'Australia East': 'australiaeast'
  'Australia Central': 'australiacentral'
  'Southeast Asia': 'southeastasia'
  /* Additional Azure regions */
  'East US': 'eastus'
  'West US 2': 'westus2'
  'Central US': 'centralus'
  'South Central US': 'southcentralus'
  'West Europe': 'westeurope'
  'North Europe': 'northeurope'
  'Japan East': 'japaneast'
  'UK South': 'uksouth'
  'Canada Central': 'canadacentral'
  'Korea Central': 'koreacentral'
  'France Central': 'francecentral'
  'Germany West Central': 'germanywestcentral'
  'Switzerland North': 'switzerlandnorth'
  'UAE North': 'uaenorth'
  'Brazil South': 'brazilsouth'
  'South Africa North': 'southafricanorth'
  'India Central': 'centralindia'
  'Norway East': 'norwayeast'
  'Sweden Central': 'swedencentral'
  'Poland Central': 'polandcentral'
}

var canonicalLocation = locationMap[location]

var tags object = {
  environment: environment
}

output location string = location
output canonicalLocation string = canonicalLocation
output environment string = environment
output tags object = tags
