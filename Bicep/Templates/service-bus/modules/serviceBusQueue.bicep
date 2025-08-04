/* Service Bus Queue Module */
@description('Name of the Service Bus Namespace')
param serviceBusNamespace string

@description('Name of the Service Bus Queue')
param queueName string

@description('Service Bus Namespace resource')
resource serviceBus 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: serviceBusNamespace
}

@description('Service Bus Queue resource')
resource serviceBus_queueExample 'Microsoft.ServiceBus/namespaces/queues@2024-01-01' = {
  parent: serviceBus
  name: queueName
  properties: {
    maxMessageSizeInKilobytes: 256
    lockDuration: 'PT1M'
    maxSizeInMegabytes: 1024 //;2048;3072;4096;5120
    requiresDuplicateDetection: true
    requiresSession: false
    defaultMessageTimeToLive: 'P14D'
    deadLetteringOnMessageExpiration: true
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    status: 'Active'
    autoDeleteOnIdle: 'P14D'
    enablePartitioning: true
    enableExpress: false
  }
}

output serviceBusQueueId string = serviceBus_queueExample.id
output serviceBusQueueName string = serviceBus_queueExample.name
