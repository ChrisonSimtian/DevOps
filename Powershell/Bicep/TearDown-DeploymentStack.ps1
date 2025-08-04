<#
.SYNOPSIS
    This script tears down a deployment stack in Azure by removing all resources in the specified resource group.
.DESCRIPTION
    This function tears down a deployment stack in Azure by removing all resources in the specified resource group
.PARAMETER ResourceGroupName
    The name of the resource group where the deployment stack is located.
.PARAMETER deploymentStackName
    The name of the deployment stack to be removed.
.EXAMPLE
    TearDown-DeploymentStack -ResourceGroupName "my-rg-ae-test" -deploymentStackName "my-app-test-deployment"
    This command tears down the specified deployment stack by removing all resources in the resource group.
#>
function TearDown-DeploymentStack {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $ResourceGroupName,

        [Parameter(Mandatory)]
        [string]
        $deploymentStackName
    )

    Write-Verbose "Tearing down deployment stack in resource group: $ResourceGroupName"

    # Remove all resources in the specified resource group
    try {
        Write-Debug "🔄 Removing resources in resource group: $ResourceGroupName"
        Remove-AzResourceGroupDeploymentStack -Name $deploymentStackName -ResourceGroupName $resourceGroupName -Force -ErrorAction Stop
        Write-Information "✅ Successfully removed resource group: $ResourceGroupName"
    } catch {
        Write-Error "Failed to remove resource group: $_"
        throw "❌ Resource group removal failed. Please check the error message: ${($_.Exception.Message)}"
    }
}