<#
.SYNOPSIS
    Retrieves an existing Azure Service Bus authorization rule.

.DESCRIPTION
    This function checks for an existing authorization rule for a specified Service Bus namespace and policy.
    It can target either a queue or a topic based on the provided parameters.

.PARAMETER ResourceGroup
    The name of the Azure resource group.

.PARAMETER Namespace
    The name of the Service Bus namespace.

.PARAMETER PolicyName
    The name of the authorization policy.

.EXAMPLE
    Get-ExistingAuthorizationRule -ResourceGroup "MyResourceGroup" -Namespace "MyNamespace" -PolicyName "MyPolicy" -EntityName "MyQueue" -IsQueue
#>
function Get-ExistingAuthorizationRule {
    param (
        [Parameter(Mandatory)]
        [string]
        $ResourceGroup,
        [Parameter(Mandatory)]
        [string]
        $Namespace,
        [Parameter(Mandatory)]
        [string]
        $PolicyName
    )
    #Requires -Module Az.ServiceBus

    # Check if getting SAS on namespace or entity
    $parameters = @{
        ResourceGroupName = $ResourceGroup
        Namespace         = $Namespace
        Name              = $PolicyName
    }

    $authRule = Get-AzServiceBusAuthorizationRule @parameters -ErrorAction Stop

    if ($null -eq $authRule) {
        Write-Verbose "No existing authorization rule found."
        return $null
    }
    else {
        return $authRule
    }
}