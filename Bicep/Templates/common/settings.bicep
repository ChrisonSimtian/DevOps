@description('Location for the resources. Defaults to Resource Group location.')
param location string = resourceGroup().location

@description('Environment')
@allowed(['CI', 'Devops', 'Prod', 'Regression', 'Test'])
param environment string

/* Location Mapping
 * This mapping is used to convert the location string to Display Name and vice versa.
 * https://gist.github.com/ausfestivus/04e55c7d80229069bf3bc75870630ec8
 */

 /* ShortName -> DisplayName */
var locationDisplayNames = {
  australiaeast: 'Australia East'
  australiasoutheast: 'Australia Southeast'
  australiacentral: 'Australia Central'
  australiacentral2: 'Australia Central 2'
  eastus: 'East US'
  eastus2: 'East US 2'
  westus: 'West US'
  westus2: 'West US 2'
  westus3: 'West US 3'
  centralus: 'Central US'
  northcentralus: 'North Central US'
  southcentralus: 'South Central US'
  northeurope: 'North Europe'
  westeurope: 'West Europe'
  francecentral: 'France Central'
  francesouth: 'France South'
  germanywestcentral: 'Germany West Central'
  germanynorth: 'Germany North'
  norwayeast: 'Norway East'
  norwaywest: 'Norway West'
  swedencentral: 'Sweden Central'
  switzerlandnorth: 'Switzerland North'
  ukwest: 'UK West'
  uksouth: 'UK South'
  canadacentral: 'Canada Central'
  canadaeast: 'Canada East'
  brazilsouth: 'Brazil South'
  brazilsoutheast: 'Brazil Southeast'
  japanwest: 'Japan West'
  japaneast: 'Japan East'
  koreacentral: 'Korea Central'
  koreasouth: 'Korea South'
  eastasia: 'East Asia'
  southeastasia: 'Southeast Asia'
  centralindia: 'Central India'
  southindia: 'South India'
  westindia: 'West India'
  indonesiacentral: 'Indonesia Central'
  malaysiasouth: 'Malaysia South'
  malaysiawest: 'Malaysia West'
  newzealandnorth: 'New Zealand North'
  israelcentral: 'Israel Central'
  qatarcentral: 'Qatar Central'
  polandcentral: 'Poland Central'
  italynorth: 'Italy North'
  spaincentral: 'Spain Central'
  mexicocentral: 'Mexico Central'
  uaenorth: 'UAE North'
  southafricanorth: 'South Africa North'
}

/* DisplayName -> ShortName */
var locationShortNames = {
  'Australia East': 'australiaeast'
  'Australia Southeast': 'australiasoutheast'
  'Australia Central': 'australiacentral'
  'Australia Central 2': 'australiacentral2'
  'East US': 'eastus'
  'East US 2': 'eastus2'
  'West US': 'westus'
  'West US 2': 'westus2'
  'West US 3': 'westus3'
  'Central US': 'centralus'
  'North Central US': 'northcentralus'
  'South Central US': 'southcentralus'
  'North Europe': 'northeurope'
  'West Europe': 'westeurope'
  'France Central': 'francecentral'
  'France South': 'francesouth'
  'Germany West Central': 'germanywestcentral'
  'Germany North': 'germanynorth'
  'Norway East': 'norwayeast'
  'Norway West': 'norwaywest'
  'Sweden Central': 'swedencentral'
  'Switzerland North': 'switzerlandnorth'
  'UK West': 'ukwest'
  'UK South': 'uksouth'
  'Canada Central': 'canadacentral'
  'Canada East': 'canadaeast'
  'Brazil South': 'brazilsouth'
  'Brazil Southeast': 'brazilsoutheast'
  'Japan West': 'japanwest'
  'Japan East': 'japaneast'
  'Korea Central': 'koreacentral'
  'Korea South': 'koreasouth'
  'East Asia': 'eastasia'
  'Southeast Asia': 'southeastasia'
  'Central India': 'centralindia'
  'South India': 'southindia'
  'West India': 'westindia'
  'Indonesia Central': 'indonesiacentral'
  'Malaysia South': 'malaysiasouth'
  'Malaysia West': 'malaysiawest'
  'New Zealand North': 'newzealandnorth'
  'Israel Central': 'israelcentral'
  'Qatar Central': 'qatarcentral'
  'Poland Central': 'polandcentral'
  'Italy North': 'italynorth'
  'Spain Central': 'spaincentral'
  'Mexico Central': 'mexicocentral'
  'UAE North': 'uaenorth'
  'South Africa North': 'southafricanorth'
}

var tags object = {
  environment: environment
}

output location string = location
output locationDisplayName string = locationDisplayNames[location]
output environment string = environment
output tags object = tags
