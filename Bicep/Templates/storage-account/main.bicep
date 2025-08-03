param name string

param location string
param environment string

module settings '../common/settings.bicep' = {
  name: 'settings'
  params: {
    location: location
    environment: environment
  }
}

module storageAccount './modules/storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    location: settings.outputs.location
    tags: settings.outputs.tags
    name: name
  }
}
