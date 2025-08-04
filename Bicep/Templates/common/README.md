# Common Settings

This is a helper module to allow shared settings across different bicep modules

## Usage

Paste this in your bicep file

```bicep
/* Common Settings Parameters */
@description('Resource Location')
param location string = resourceGroup().location

@description('Resource Tags')
@allowed(['CI', 'Devops', 'Prod', 'Regression', 'Test'])
param environment string
```

```bicep
/* Common Settings */
module settings '../common/settings.bicep' = {
  name: 'settings'
  params: {
    location: location
    environment: environment
  }
}
```
