<#
.SYNOPSIS
    Deploys a Bicep template to create a Service Bus Namespace and related resources.
.DESCRIPTION
    This function deploys a Bicep template to create a Service Bus Namespace and related resources.
.PARAMETER tenantId
    The Azure Active Directory tenant ID to use for the connection.
.PARAMETER subscriptionId
    The Azure subscription ID to use for the deployment.
.PARAMETER location
    The Azure region where the resources will be deployed.
.PARAMETER resourceGroupName
    The name of the resource group where the resources will be deployed.
.PARAMETER deploymentStackName
    The name of the deployment stack to create or update.
.EXAMPLE
    Deploy-BicepAsDeploymentStack -tenantId "4db41075-b108-4ef0-b2b7-5bc4e44430fb" -subscriptionId "9f6bbd17-3dae-40c3-87c5-59ac961a8f72" -location "australiaeast" -resourceGroupName "mfb-erp-dev" -deploymentStackName "mfb-erp-dev-deployment"
    This command deploys the Bicep template to create a Service Bus Namespace and related resources.
#>
function Deploy-BicepAsDeploymentStack {
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
        $location,

        [Parameter(Mandatory)]
        [string]
        $resourceGroupName,

        [Parameter(Mandatory)]
        [string]
        $deploymentStackName,

        [Parameter()]
        [string]
        $bicepFilePath = "main.bicep",

        [Parameter()]
        [string]
        $bicepParamFilePath = "main.bicepparam"
    )
    # Sources:
    # https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/quickstart-create-deployment-stacks?tabs=azure-powershell%2CCLI

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
        New-AzResourceGroup -Name $resourceGroupName -Location $location
        Write-Information "✅ Resource group '$resourceGroupName' created successfully."
    }

    try {
        # Make sure were in the correct directory
        Set-Location $PSScriptRoot

        # Resolve the Bicep file paths
        Write-Debug "🔄 Resolving Bicep file paths..."
        $bicepFilePath = Join-Path -Path $PSScriptRoot -ChildPath $bicepFilePath
        if (-not (Test-Path $bicepFilePath)) {
            Write-Error "🔴 Bicep file '$bicepFilePath' not found. Please ensure the file exists."
            throw "❌ Bicep file not found. Please check the path and try again."
        }
        Write-Debug "✅ Bicep file resolved: $bicepFilePath"

        $bicepParamFilePath = Join-Path -Path $PSScriptRoot -ChildPath $bicepParamFilePath
        if (-not (Test-Path $bicepParamFilePath)) {
            Write-Error "🔴 Bicep parameter file '$bicepParamFilePath' not found. Please ensure the file exists."
            throw "❌ Bicep parameter file not found. Please check the path and try again."
        }
        Write-Debug "✅ Bicep file resolved: $bicepParamFilePath"

        Write-Debug "🔄 Creating or updating deployment stack '$deploymentStackName' in resource group '$resourceGroupName'."
        # Create or update the deployment stack using the Bicep template
        # https://learn.microsoft.com/en-us/powershell/module/az.resources/new-azresourcegroupdeploymentstack?view=azps-14.2.0
        $result = New-AzResourceGroupDeploymentStack `
            -Name $deploymentStackName `
            -ResourceGroupName $resourceGroupName `
            -TemplateFile $bicepFilePath `
            -TemplateParameterFile $bicepParamFilePath `
            -ActionOnUnmanage "detachAll" `
            -DenySettingsMode "none" `
            -Force # Do not ask for confirmation when overwriting an existing stack.

        $duration = Get-TimeSpan -durationString $result.duration
        Write-Information "📦 Deployment stack '$deploymentStackName' created or updated successfully. Duration: $duration seconds"
    }
    catch {
        Write-Error "🔴 Failed to create deployment stack: $_"
        throw "❌ Deployment stack creation failed. Please check the error message. ${($_.Exception.Message)}"
    }

    # Output the deployment stack details
    $deploymentStack = Get-AzResourceGroupDeploymentStack -Name $deploymentStackName -ResourceGroupName $resourceGroupName
    if ($deploymentStack) {
        Write-Verbose "Deployment Stack '$deploymentStackName' details:"
        Write-Verbose "Location: $($deploymentStack.Location)"
        Write-Verbose "Provisioning State: $($deploymentStack.ProvisioningState)"
        Write-Verbose "Tags: $($deploymentStack.Tags)"
    }
    else {
        Write-Error "🔴 Deployment Stack '$deploymentStackName' not found."
    }

    # Delete the deployment stack if needed
    # Uncomment the following lines to delete the deployment stack after use

    # https://learn.microsoft.com/en-us/powershell/module/az.resources/remove-azresourcegroupdeploymentstack?view=azps-14.2.0
    # Write-Information "Deleting Deployment Stack '$deploymentStackName'..."
    # Remove-AzResourceGroupDeploymentStack -Name $deploymentStackName -ResourceGroupName $resourceGroupName
}