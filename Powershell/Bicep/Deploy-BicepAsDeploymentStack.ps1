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
.PARAMETER bicepFilePath
    The path to the Bicep file that defines the resources to be deployed.
.PARAMETER bicepParamFilePath
    The path to the Bicep parameter file that provides parameters for the deployment.
.EXAMPLE
    Deploy-BicepAsDeploymentStack -tenantId "00000000-0000-0000-0000-000000000000" -subscriptionId "00000000-0000-0000-0000-000000000000" -location "australiaeast" -resourceGroupName "my-rg-dev" -deploymentStackName "my-deploymentStack" -bicepFilePath "C:\path\to\main.bicep" -bicepParamFilePath "C:\path\to\main.bicepparam.json"
    This command deploys a Bicep template to create a Service Bus Namespace and related resources in the specified resource group and location.
.OUTPUTS
    Outputs the details of the created or updated deployment stack, including its location, provisioning state, and tags.
.NOTES
    Requires the Az.Resources module to be installed.
    Ensure that the Bicep file and parameter file paths are correct before running the script.
    The script will create a new resource group if it does not already exist.
    The deployment stack will be created or updated with the specified parameters.
    If the deployment stack already exists, it will be updated with the new parameters.
    The script will output the details of the deployment stack after creation or update.
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

        [Parameter(Mandatory)]
        [string]
        $bicepFilePath,

        [Parameter(Mandatory)]
        [string]
        $bicepParamFilePath
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
        $bicepFilePath = $bicepFilePath
        if (-not (Test-Path $bicepFilePath)) {
            Write-Error "🔴 Bicep file '$bicepFilePath' not found. Please ensure the file exists."
            throw "❌ Bicep file not found. Please check the path and try again."
        }
        Write-Debug "✅ Bicep file resolved: $bicepFilePath"

        $bicepParamFilePath = $bicepParamFilePath
        if (-not (Test-Path $bicepParamFilePath)) {
            Write-Error "🔴 Bicep parameter file '$bicepParamFilePath' not found. Please ensure the file exists."
            throw "❌ Bicep parameter file not found. Please check the path and try again."
        }
        Write-Debug "✅ Bicep file resolved: $bicepParamFilePath"

        Write-Debug "🔄 Creating or updating deployment stack '$deploymentStackName' in resource group '$resourceGroupName'."
        # Create or update the deployment stack using the Bicep template
        # https://learn.microsoft.com/en-us/powershell/module/az.resources/new-azresourcegroupdeploymentstack?view=azps-14.2.0
        $deploymentStackParameters = @{
            Name                  = $deploymentStackName
            ResourceGroupName     = $resourceGroupName
            TemplateFile          = $bicepFilePath
            TemplateParameterFile = $bicepParamFilePath
            ActionOnUnmanage      = "detachAll"
            DenySettingsMode      = "DenyDelete"
            # Uncomment the following line to exclude specific principals from deny settings
            # DenySettingsExcludedPrincipal = @('00000000-0000-0000-0000-000000000000')
            Force                 = $true # Do not ask for confirmation when overwriting an existing stack.
        }
        $result = New-AzResourceGroupDeploymentStack $deploymentStackParameters

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
}