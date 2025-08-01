<#
.SYNOPSIS
    Deploys an Azure Resource Group with specified parameters.
.DESCRIPTION
    This script connects to an Azure account and deploys a resource group with the specified name, location, and environment. It checks if the resource group already exists before attempting to create it.
.PARAMETER tenantId
    The Azure Active Directory tenant ID.
.PARAMETER subscriptionId
    The Azure subscription ID where the resource group will be created.
.PARAMETER resourceGroupName
    The name of the resource group to create or update.
.PARAMETER location
    The Azure region where the resource group will be created.
.PARAMETER environment
    The environment for the resource group (e.g., Development, Test, Staging, Production).
.EXAMPLE
    Deploy-ResourceGroup -tenantId "12345678-1234-1234-123456789012" `
                        -subscriptionId "87654321-4321-4321-4321-210987654321" `
                        -resourceGroupName "MyResourceGroup" `
                        -location "East US" `
                        -environment "Development"
#>
function Deploy-ResourceGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [guid]
        $tenantId,

        [Parameter(Mandatory)]
        [guid]
        $subscriptionId,

        [Parameter(Mandatory)]
        [string]
        $resourceGroupName,

        [Parameter(Mandatory)]
        [string]
        $location,
        
        [Parameter(Mandatory)]
        [ValidateSet("Development", "Test", "Staging", "Production")]
        [string]
        $environment
    )
    #Requires -Version 5.1
    #Requires -Modules Az, Az.Resources
    
    # Connect to Azure account
    if (-not (Get-AzContext)) {
        Write-Debug "🔄 No Azure context found. Connecting to Azure..."
        Connect-AzAccount -Tenant $tenantId -SubscriptionId $subscriptionId
        Write-Information "✅ Connected to Azure account."
    }
    else {
        Write-Verbose "☑️ Azure context already exists."
    }

    # Create a new resource group and deploy the Bicep template
    if (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue) {
        Write-Information "☑️ Resource group '$resourceGroupName' already exists. Skipping creation."
    }
    else {
        Write-Debug "🔄 Creating resource group '$resourceGroupName' in location '$location'."
        $result = New-AzResourceGroup -Name $resourceGroupName -Location $location -Tag @{ Environment = $environment } -ErrorAction SilentlyContinue
        if (-not $result) {
            Write-Error "❌ Failed to create resource group '$resourceGroupName'."
            throw "Resource group creation failed."
        }
        Write-Information "✅ Resource group '$resourceGroupName' created successfully."
    }
}