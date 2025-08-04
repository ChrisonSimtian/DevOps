/* Service Bus Topic Module */
@description('Name of the Service Bus Namespace')
param serviceBusNamespace string

@description('Name of the Service Bus Topic')
param topicName string

@description('Service Bus Namespace resource')
resource serviceBus 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: serviceBusNamespace
}

@description('Service Bus Topic resource')
resource serviceBus_topicExample 'Microsoft.ServiceBus/namespaces/topics@2024-01-01' = {
  parent: serviceBus
  name: topicName
  properties: {
    maxMessageSizeInKilobytes: 256
    defaultMessageTimeToLive: 'P14D'
    maxSizeInMegabytes: 1024 //;2048;3072;4096;5120
    requiresDuplicateDetection: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    enableBatchedOperations: true
    status: 'Active'
    supportOrdering: true
    autoDeleteOnIdle: 'P14D'
    enablePartitioning: true
    enableExpress: false
  }
}

output serviceBusTopicId string = serviceBus_topicExample.id
output serviceBusTopicName string = serviceBus_topicExample.name
