param name string
param location string
param tags object

resource storageAccount_Resource 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    largeFileSharesState: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

output Id string = storageAccount_Resource.id
output Name string = storageAccount_Resource.name
output PrimaryEndpoints object = storageAccount_Resource.properties.primaryEndpoints
output ApiVersion string = storageAccount_Resource.apiVersion

resource storageAccount_BlobService_Resource 'Microsoft.Storage/storageAccounts/blobServices@2025-01-01' = {
  parent: storageAccount_Resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 7
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource storageAccount_FileService_Resource 'Microsoft.Storage/storageAccounts/fileServices@2025-01-01' = {
  parent: storageAccount_Resource
  name: 'default'
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}



resource storageAccounts_mfberpfuncstorageaetest_name_default_azure_webjobs_hosts 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-01-01' = {
  parent: storageAccount_BlobService_Resource
  name: 'azure-webjobs-hosts'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

resource storageAccounts_mfberpfuncstorageaetest_name_default_azure_webjobs_secrets 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-01-01' = {
  parent: storageAccount_BlobService_Resource
  name: 'azure-webjobs-secrets'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}
