param sites_mfb_erp_func_ae_test_name string = 'mfb-erp-func-ae-test'
param serverfarms_ASP_mfberptest_a1ee_name string = 'ASP-mfberptest-a1ee'
param components_mfb_erp_func_ae_test_name string = 'mfb-erp-func-ae-test'
param storageAccounts_mfberpfuncstorageaetest_name string = 'mfberpfuncstorageaetest'
param workspaces_DefaultWorkspace_9f6bbd17_3dae_40c3_87c5_59ac961a8f72_EAU_externalid string = '/subscriptions/9f6bbd17-3dae-40c3-87c5-59ac961a8f72/resourceGroups/DefaultResourceGroup-EAU/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-9f6bbd17-3dae-40c3-87c5-59ac961a8f72-EAU'

resource components_mfb_erp_func_ae_test_name_resource 'microsoft.insights/components@2020-02-02' = {
  name: components_mfb_erp_func_ae_test_name
  location: 'australiaeast'
  tags: {
    environment: 'Test'
  }
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaWebAppExtensionCreate'
    RetentionInDays: 90
    WorkspaceResourceId: workspaces_DefaultWorkspace_9f6bbd17_3dae_40c3_87c5_59ac961a8f72_EAU_externalid
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    DisableLocalAuth: false
  }
}

resource storageAccounts_mfberpfuncstorageaetest_name_resource 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: storageAccounts_mfberpfuncstorageaetest_name
  location: 'australiaeast'
  tags: {
    environment: 'Test'
  }
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
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

resource serverfarms_ASP_mfberptest_a1ee_name_resource 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: serverfarms_ASP_mfberptest_a1ee_name
  location: 'Australia East'
  tags: {
    environment: 'Test'
  }
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

resource components_mfb_erp_func_ae_test_name_degradationindependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_mfb_erp_func_ae_test_name_resource
  name: 'degradationindependencyduration'
  location: 'australiaeast'
  properties: {
    RuleDefinitions: {
      Name: 'degradationindependencyduration'
      DisplayName: 'Degradation in dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_mfb_erp_func_ae_test_name_degradationinserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_mfb_erp_func_ae_test_name_resource
  name: 'degradationinserverresponsetime'
  location: 'australiaeast'
  properties: {
    RuleDefinitions: {
      Name: 'degradationinserverresponsetime'
      DisplayName: 'Degradation in server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_mfb_erp_func_ae_test_name_digestMailConfiguration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_mfb_erp_func_ae_test_name_resource
  name: 'digestMailConfiguration'
  location: 'australiaeast'
  properties: {
    RuleDefinitions: {
      Name: 'digestMailConfiguration'
      DisplayName: 'Digest Mail Configuration'
      Description: 'This rule describes the digest mail preferences'
      HelpUrl: 'www.homail.com'
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_mfb_erp_func_ae_test_name_extension_billingdatavolumedailyspikeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_mfb_erp_func_ae_test_name_resource
  name: 'extension_billingdatavolumedailyspikeextension'
  location: 'australiaeast'
  properties: {
    RuleDefinitions: {
      Name: 'extension_billingdatavolumedailyspikeextension'
      DisplayName: 'Abnormal rise in daily data volume (preview)'
      Description: 'This detection rule automatically analyzes the billing data generated by your application, and can warn you about an unusual increase in your application\'s billing costs'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/billing-data-volume-daily-spike.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_mfb_erp_func_ae_test_name_extension_canaryextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_mfb_erp_func_ae_test_name_resource
  name: 'extension_canaryextension'
  location: 'australiaeast'
  properties: {
    RuleDefinitions: {
      Name: 'extension_canaryextension'
      DisplayName: 'Canary extension'
      Description: 'Canary extension'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/'
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_mfb_erp_func_ae_test_name_extension_exceptionchangeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_mfb_erp_func_ae_test_name_resource
  name: 'extension_exceptionchangeextension'
  location: 'australiaeast'
  properties: {
    RuleDefinitions: {
      Name: 'extension_exceptionchangeextension'
      DisplayName: 'Abnormal rise in exception volume (preview)'
      Description: 'This detection rule automatically analyzes the exceptions thrown in your application, and can warn you about unusual patterns in your exception telemetry.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/abnormal-rise-in-exception-volume.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_mfb_erp_func_ae_test_name_extension_memoryleakextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_mfb_erp_func_ae_test_name_resource
  name: 'extension_memoryleakextension'
  location: 'australiaeast'
  properties: {
    RuleDefinitions: {
      Name: 'extension_memoryleakextension'
      DisplayName: 'Potential memory leak detected (preview)'
      Description: 'This detection rule automatically analyzes the memory consumption of each process in your application, and can warn you about potential memory leaks or increased memory consumption.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/tree/master/SmartDetection/memory-leak.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_mfb_erp_func_ae_test_name_extension_securityextensionspackage 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_mfb_erp_func_ae_test_name_resource
  name: 'extension_securityextensionspackage'
  location: 'australiaeast'
  properties: {
    RuleDefinitions: {
      Name: 'extension_securityextensionspackage'
      DisplayName: 'Potential security issue detected (preview)'
      Description: 'This detection rule automatically analyzes the telemetry generated by your application and detects potential security issues.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/application-security-detection-pack.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_mfb_erp_func_ae_test_name_extension_traceseveritydetector 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_mfb_erp_func_ae_test_name_resource
  name: 'extension_traceseveritydetector'
  location: 'australiaeast'
  properties: {
    RuleDefinitions: {
      Name: 'extension_traceseveritydetector'
      DisplayName: 'Degradation in trace severity ratio (preview)'
      Description: 'This detection rule automatically analyzes the trace logs emitted from your application, and can warn you about unusual patterns in the severity of your trace telemetry.'
      HelpUrl: 'https://github.com/Microsoft/ApplicationInsights-Home/blob/master/SmartDetection/degradation-in-trace-severity-ratio.md'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_mfb_erp_func_ae_test_name_longdependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_mfb_erp_func_ae_test_name_resource
  name: 'longdependencyduration'
  location: 'australiaeast'
  properties: {
    RuleDefinitions: {
      Name: 'longdependencyduration'
      DisplayName: 'Long dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_mfb_erp_func_ae_test_name_migrationToAlertRulesCompleted 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_mfb_erp_func_ae_test_name_resource
  name: 'migrationToAlertRulesCompleted'
  location: 'australiaeast'
  properties: {
    RuleDefinitions: {
      Name: 'migrationToAlertRulesCompleted'
      DisplayName: 'Migration To Alert Rules Completed'
      Description: 'A configuration that controls the migration state of Smart Detection to Smart Alerts'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: true
      IsEnabledByDefault: false
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: false
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_mfb_erp_func_ae_test_name_slowpageloadtime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_mfb_erp_func_ae_test_name_resource
  name: 'slowpageloadtime'
  location: 'australiaeast'
  properties: {
    RuleDefinitions: {
      Name: 'slowpageloadtime'
      DisplayName: 'Slow page load time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_mfb_erp_func_ae_test_name_slowserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_mfb_erp_func_ae_test_name_resource
  name: 'slowserverresponsetime'
  location: 'australiaeast'
  properties: {
    RuleDefinitions: {
      Name: 'slowserverresponsetime'
      DisplayName: 'Slow server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource storageAccounts_mfberpfuncstorageaetest_name_default 'Microsoft.Storage/storageAccounts/blobServices@2025-01-01' = {
  parent: storageAccounts_mfberpfuncstorageaetest_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
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

resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_mfberpfuncstorageaetest_name_default 'Microsoft.Storage/storageAccounts/fileServices@2025-01-01' = {
  parent: storageAccounts_mfberpfuncstorageaetest_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
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

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_mfberpfuncstorageaetest_name_default 'Microsoft.Storage/storageAccounts/queueServices@2025-01-01' = {
  parent: storageAccounts_mfberpfuncstorageaetest_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_mfberpfuncstorageaetest_name_default 'Microsoft.Storage/storageAccounts/tableServices@2025-01-01' = {
  parent: storageAccounts_mfberpfuncstorageaetest_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource sites_mfb_erp_func_ae_test_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-11-01' = {
  parent: sites_mfb_erp_func_ae_test_name_resource
  name: 'ftp'
  location: 'Australia East'
  tags: {
    environment: 'Test'
    'hidden-link: /app-insights-resource-id': '/subscriptions/9f6bbd17-3dae-40c3-87c5-59ac961a8f72/resourceGroups/mfb-erp-test/providers/Microsoft.Insights/components/mfb-erp-func-ae-test'
  }
  properties: {
    allow: false
  }
}

resource sites_mfb_erp_func_ae_test_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-11-01' = {
  parent: sites_mfb_erp_func_ae_test_name_resource
  name: 'scm'
  location: 'Australia East'
  tags: {
    environment: 'Test'
    'hidden-link: /app-insights-resource-id': '/subscriptions/9f6bbd17-3dae-40c3-87c5-59ac961a8f72/resourceGroups/mfb-erp-test/providers/Microsoft.Insights/components/mfb-erp-func-ae-test'
  }
  properties: {
    allow: false
  }
}

resource sites_mfb_erp_func_ae_test_name_web 'Microsoft.Web/sites/config@2024-11-01' = {
  parent: sites_mfb_erp_func_ae_test_name_resource
  name: 'web'
  location: 'Australia East'
  tags: {
    environment: 'Test'
    'hidden-link: /app-insights-resource-id': '/subscriptions/9f6bbd17-3dae-40c3-87c5-59ac961a8f72/resourceGroups/mfb-erp-test/providers/Microsoft.Insights/components/mfb-erp-func-ae-test'
  }
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
    ]
    netFrameworkVersion: 'v4.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: 'REDACTED'
    scmType: 'None'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    publicNetworkAccess: 'Enabled'
    cors: {
      allowedOrigins: [
        'https://portal.azure.com'
      ]
      supportCredentials: false
    }
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    functionAppScaleLimit: 100
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
    http20ProxyFlag: 0
  }
}

resource sites_mfb_erp_func_ae_test_name_sites_mfb_erp_func_ae_test_name_b6ggepgke4gbdbfy_australiaeast_01_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2024-11-01' = {
  parent: sites_mfb_erp_func_ae_test_name_resource
  name: '${sites_mfb_erp_func_ae_test_name}-b6ggepgke4gbdbfy.australiaeast-01.azurewebsites.net'
  location: 'Australia East'
  properties: {
    siteName: 'mfb-erp-func-ae-test'
    hostNameType: 'Verified'
  }
}

resource storageAccounts_mfberpfuncstorageaetest_name_default_app_package_mfb_erp_func_ae_test_7a18d01 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-01-01' = {
  parent: storageAccounts_mfberpfuncstorageaetest_name_default
  name: 'app-package-mfb-erp-func-ae-test-7a18d01'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_mfberpfuncstorageaetest_name_resource
  ]
}

resource storageAccounts_mfberpfuncstorageaetest_name_default_azure_webjobs_hosts 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-01-01' = {
  parent: storageAccounts_mfberpfuncstorageaetest_name_default
  name: 'azure-webjobs-hosts'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_mfberpfuncstorageaetest_name_resource
  ]
}

resource storageAccounts_mfberpfuncstorageaetest_name_default_azure_webjobs_secrets 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-01-01' = {
  parent: storageAccounts_mfberpfuncstorageaetest_name_default
  name: 'azure-webjobs-secrets'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_mfberpfuncstorageaetest_name_resource
  ]
}

resource storageAccounts_mfberpfuncstorageaetest_name_default_AzureFunctionsDiagnosticEvents202508 'Microsoft.Storage/storageAccounts/tableServices/tables@2025-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_mfberpfuncstorageaetest_name_default
  name: 'AzureFunctionsDiagnosticEvents202508'
  properties: {}
  dependsOn: [
    storageAccounts_mfberpfuncstorageaetest_name_resource
  ]
}

resource sites_mfb_erp_func_ae_test_name_resource 'Microsoft.Web/sites@2024-11-01' = {
  name: sites_mfb_erp_func_ae_test_name
  location: 'Australia East'
  tags: {
    environment: 'Test'
    'hidden-link: /app-insights-resource-id': '/subscriptions/9f6bbd17-3dae-40c3-87c5-59ac961a8f72/resourceGroups/mfb-erp-test/providers/Microsoft.Insights/components/mfb-erp-func-ae-test'
  }
  kind: 'functionapp,linux'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_mfb_erp_func_ae_test_name}-b6ggepgke4gbdbfy.australiaeast-01.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_mfb_erp_func_ae_test_name}-b6ggepgke4gbdbfy.scm.australiaeast-01.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_ASP_mfberptest_a1ee_name_resource.id
    reserved: true
    isXenon: false
    hyperV: false
    dnsConfiguration: {}
    outboundVnetRouting: {
      allTraffic: false
      applicationTraffic: false
      contentShareTraffic: false
      imagePullTraffic: false
      backupRestoreTraffic: false
    }
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 100
      minimumElasticInstanceCount: 0
    }
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobcontainer'
          value: 'https://${storageAccounts_mfberpfuncstorageaetest_name}.blob.core.windows.net/app-package-${sites_mfb_erp_func_ae_test_name}-7a18d01'
          authentication: {
            type: 'storageaccountconnectionstring'
            storageAccountConnectionStringName: 'DEPLOYMENT_STORAGE_CONNECTION_STRING'
          }
        }
      }
      runtime: {
        name: 'dotnet-isolated'
        version: '8.0'
      }
      scaleAndConcurrency: {
        maximumInstanceCount: 100
        instanceMemoryMB: 2048
      }
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientAffinityProxyEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    ipMode: 'IPv4'
    customDomainVerificationId: '57523E2379AF4976A849FE93FFEEB277EC9266162012D00EBB3E76B0905C0967'
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    endToEndEncryptionEnabled: false
    redundancyMode: 'None'
    publicNetworkAccess: 'Enabled'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
    autoGeneratedDomainNameLabelScope: 'TenantReuse'
  }
  dependsOn: [
    storageAccounts_mfberpfuncstorageaetest_name_resource
  ]
}
