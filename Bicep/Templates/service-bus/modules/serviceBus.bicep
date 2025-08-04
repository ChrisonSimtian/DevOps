/* Service Bus Module */
param serviceBusNamespace string
param location string
param tags object

@description('Namespace for the Service Bus')
resource serviceBus 'Microsoft.ServiceBus/namespaces@2024-01-01' = {
  name: serviceBusNamespace
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  tags: tags
  properties: {
    premiumMessagingPartitions: 0
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: true
  }
}

@description('Authorization rule for the Service Bus Namespace')
resource serviceBus_RootManageSharedAccessKey 'Microsoft.ServiceBus/namespaces/authorizationrules@2024-01-01' = {
  parent: serviceBus
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

@description('Network rules for the Service Bus Namespace')
resource serviceBus_default 'Microsoft.ServiceBus/namespaces/networkrulesets@2024-01-01' = {
  parent: serviceBus
  name: 'default'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    trustedServiceAccessEnabled: false
  }
}

output serviceBusNamespaceId string = serviceBus.id
output serviceBusNamespaceName string = serviceBus.name
