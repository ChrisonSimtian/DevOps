<#
#>
function Deploy-AuthorizationRule {
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
        [string]
        $EntityName,
        [string[]]
        $Rights = @("Send", "Listen"),
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

    # Check if setting SAS on namespace or entity
    $parameters = @{
        ResourceGroupName = $ResourceGroup
        Namespace         = $Namespace
        Name              = $PolicyName
        Rights            = $Rights
    }

    if ($IsQueue.IsPresent) {
        $parameters.QueueName = $EntityName
    }
    elseif ($IsTopic.IsPresent) {
        $parameters.TopicName = $EntityName
    }

    $existingRule = Get-ExistingAuthorizationRule -ResourceGroup $ResourceGroup -Namespace $Namespace -PolicyName $PolicyName

    if($null -eq $existingRule) {
        Write-Verbose "No existing authorization rule found."
        Write-Information "Creating new authorization rule."
        $result = New-AzServiceBusAuthorizationRule @parameters
    }
    else {
        Write-Verbose "Existing authorization rule found."
        Write-Information "Updating existing authorization rule."
        $result = Set-AzServiceBusAuthorizationRule @parameters
    }

    if($null -eq $result) {
        Write-Error "Failed to create or update the authorization rule."
        throw "Failed to create or update the authorization rule."
    }
    else {
        Write-Information "Authorization rule created or updated successfully."
    }
}