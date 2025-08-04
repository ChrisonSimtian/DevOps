@description('Name of the Service Bus Namespace')
param serviceBusNamespace string

/* Common Settings Parameters */
@description('Resource Location')
param location string = resourceGroup().location

@description('Resource Tags')
@allowed(['CI', 'Devops', 'Prod', 'Regression', 'Test'])
param environment string

/* Common Settings */
module settings '../common/settings.bicep' = {
  name: 'settings'
  params: {
    location: location
    environment: environment
  }
}

module serviceBus 'modules/serviceBus.bicep' = {
  name: 'serviceBusModule'
  params: {
    serviceBusNamespace: serviceBusNamespace
    location: settings.outputs.location
    tags: settings.outputs.tags
  }
}

module serviceBusQueue 'modules/serviceBusQueue.bicep' = {
  name: 'serviceBusQueueModule'
  params: {
    serviceBusNamespace: serviceBus.outputs.serviceBusNamespaceName
    queueName: 'example-queue'
  }
}

module serviceBusTopic 'modules/serviceBusTopic.bicep' = {
  name: 'serviceBusTopicModule'
  params: {
    serviceBusNamespace: serviceBus.outputs.serviceBusNamespaceName
    topicName: 'example-topic'
  }
}
