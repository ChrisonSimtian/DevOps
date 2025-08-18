<#
.SYNOPSIS
    Sets a SAS token key for an Azure Service Bus authorization rule.
.DESCRIPTION
    This function sets a specified SAS token key (Primary or Secondary) for a Service Bus authorization rule.
    It can target either a queue or a topic based on the provided parameters.
.PARAMETER ResourceGroup
    The name of the Azure resource group.
.PARAMETER Namespace
    The name of the Service Bus namespace.
.PARAMETER PolicyName
    The name of the authorization policy.
.PARAMETER KeyType
    The type of key to set, either "PrimaryKey" or "SecondaryKey".
.PARAMETER KeyValue
    The value of the key to set.
.PARAMETER EntityName
    The name of the queue or topic. This is required if IsQueue or IsTopic is specified.
.PARAMETER IsQueue
    Indicates if the entity is a queue. If specified, EntityName must be a queue name.
.PARAMETER IsTopic
    Indicates if the entity is a topic. If specified, EntityName must be a topic name.
.EXAMPLE
    Set-SasTokenKey -ResourceGroup "MyResourceGroup" -Namespace "MyNamespace" -PolicyName "MyPolicy" -KeyType "PrimaryKey" -KeyValue "myPrimaryKey" -EntityName "MyQueue" -IsQueue
    Sets the primary key for the specified queue authorization rule.
#>
function Set-SasTokenKey {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $ResourceGroup,
        [Parameter(Mandatory)]
        [string]
        $Namespace,
        [Parameter(Mandatory)]
        [string]
        $PolicyName,
        [Parameter(Mandatory)]
        [string]
        [ValidateSet("PrimaryKey", "SecondaryKey")]
        $KeyType,
        [Parameter(Mandatory)]
        [string]
        $KeyValue,
        [string]
        $EntityName,
        [switch]
        $IsQueue = $false,
        [switch]
        $IsTopic = $false
    )
    #Requires -Module Az.ServiceBus

    # Variables
    $isGlobalRule = !$IsQueue.IsPresent -or !$IsTopic.IsPresent
    $hasEntityNameSet = ![string]::IsNullOrEmpty($EntityName)

    #region Validation
    # Validate that only one of both is being used
    if ($IsQueue.IsPresent -and $IsTopic.IsPresent) {
        # Both QueueName and TopicName are specified
        throw "Cannot specify both IsTopic and IsQueue."
    }

    # Validate EntityName set when using IsQueue or IsTopic
    
    if (!$isGlobalRule -and !$hasEntityNameSet) {
        Write-Error "EntityName must be specified when IsQueue or IsTopic is not used."
        throw "EntityName must be specified when IsQueue or IsTopic is not used."
    }

    # Warn about EntityName set when not using IsQueue or IsTopic
    if ($hasEntityNameSet -and $isGlobalRule) {
        Write-Warning "EntityName set when IsQueue or IsTopic is not used."
    }
    #endregion

    $parameters = @{
        ResourceGroupName = $ResourceGroup
        Namespace         = $Namespace
        Name              = $PolicyName
        KeyType           = $KeyType
        KeyValue          = $KeyValue
    }

    # Set Queue or Topic Name
    if ($isGlobalRule) {
        if ($IsQueue.IsPresent) {
            $parameters.QueueName = $EntityName
        }
        if ($IsTopic.IsPresent) {
            $parameters.TopicName = $EntityName
        }
    }

    $result = New-AzServiceBusKey @parameters

    if ($null -eq $result) {
        Write-Error "Failed to set SAS token key."
        throw "Failed to set SAS token key."
    }
    else {
        Write-Information "SAS token key set successfully."
    }
}