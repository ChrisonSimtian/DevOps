$subscriptionId = '9f6bbd17-3dae-40c3-87c5-59ac961a8f72'
$resourceGroupName = 'mfb-erp-ae-dev'
$namespace = 'mfb-erp-ae-dev-chris-poc'

# https://learn.microsoft.com/en-us/powershell/module/az.servicebus/?view=azps-14.2.0

# Check for Azure Arm Module and warn that the Az module is preferred
if (Get-Module -Name AzureRM -ListAvailable) {
    # https://learn.microsoft.com/en-us/powershell/azure/troubleshooting?view=azps-14.2.0#az-and-azurerm-coexistence
    Write-Warning "AzureRM module is installed. It is recommended to use the Az module instead."
    Write-Warning "Please consider migrating to the Az module for future compatibility."
}

# Ensure the Az module is installed and imported
if( -not (Get-Module -Name Az -ListAvailable)) {
    Write-Warning "Az module not found. Installing..."
    Install-Module -Name Az -Scope CurrentUser -Force -ErrorAction Continue
    Write-Verbose "Az module installed successfully."
    Import-Module Az -Force
} else {
    Write-Verbose "Az module is already installed."
}
Import-Module Az.ServiceBus

# Connect to Azure account
if (-not (Get-AzContext)) {
    Write-Verbose "No Azure context found. Connecting to Azure..."
    Connect-AzAccount #-SubscriptionId $subscriptionId -ErrorAction Stop
} else {
    Write-Verbose "Azure context already exists."
}

# Check if the Service Bus Namespace exists
$result = Get-AzServiceBusNamespace -Name $namespace -ResourceGroupName $resourceGroupName -SubscriptionId $subscriptionId

if ($null -ne $result) {
    Write-Information "Here is your Service Bus Namespace..."
    $result | ForEach-Object {
    $namespace = $_
    Write-Debug "Namespace: $($namespace.Name)"
    Write-Debug "Location: $($namespace.Location)"
    Write-Debug "SKU: $($namespace.Sku.Name)"
    Write-Debug "Tags: $($namespace.Tags)"
}
} else {
    Write-Error "Service Bus Namespace doesnt exists."
}