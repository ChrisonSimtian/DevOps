[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [guid]
    $servicePrincipalId = "62fdad3e-643c-493d-bad2-561b89b8b378", # test service principal ID
    # $servicePrincipalId = "8a83567d-41cf-4d68-999f-3c3e94eff862", # prod service principal ID

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [guid]
    $groupId = "8e1449e1-2627-40c2-a88e-07604f79c862", # Security group ID for "Users | Access | Power BI | Fabric Public API Calls Allowed"

    $groupName = "Users | Access | Power BI | Fabric Public API Calls Allowed"
)

<#
    .SYNOPSIS
    Adds a service principal to a specified Azure AD group.
    .DESCRIPTION
    This script adds a service principal to a specified Azure AD group using Azure CLI.
    .PARAMETER servicePrincipalId
    The ID of the service principal to be added to the group.
    .PARAMETER groupId
    The ID of the Azure AD group to which the service principal will be added.
    .EXAMPLE
    .\Add-ServicePrincipalToGroup.ps1 -servicePrincipalId "62fdad3e-643c-493d-bad2-561b89b8b378" -groupId "8e1449e1-2627-40c2-a88e-07604f79c862"
    Adds the specified service principal to the specified Azure AD group.
#>
function Add-ServicePrincipalToGroup {
    param (
        [Parameter(Mandatory = $true)]
        [guid]
        $servicePrincipalId,
        [Parameter(Mandatory = $true)]
        [guid]
        $groupId
    )

    try {
        az ad group member add -g $groupId --member-id $servicePrincipalId
    }
    catch {
        Write-Debug "Failed to add service principal to group: $_"
    }
}

<#
    .SYNOPSIS
    Retrieves members of a specified Azure AD group.
    .DESCRIPTION
    This script retrieves the members of a specified Azure AD group using Azure CLI and Microsoft Graph API.
    .PARAMETER groupId
    The ID of the Azure AD group whose members will be retrieved.
    .EXAMPLE
    .\Get-ServicePrincipalMembers.ps1 -groupId "8e1449e1-2627-40c2-a88e-07604f79c862"
    Retrieves the members of the specified Azure AD group.
#>
function Get-ServicePrincipalMembers {
    param (
        [Parameter(Mandatory = $true)]
        [guid]
        $groupId
    )

    try {
        $group = az rest --method get --url "https://graph.microsoft.com/beta/groups/$groupId/members" | ConvertFrom-Json # jq -r ".value | .[] | [.displayName,.id] | @tsv"
        if ($group -and $group.value) {
            foreach ($member in $group.value) {
                Write-Output "$($member.displayName) - $($member.id)"
            }
        }
        else {
            Write-Output "No members found in the group."
        }
    }
    catch {
        Write-Debug "Failed to retrieve group members: $_"
    }
}

<#
    .SYNOPSIS
    Retrieves the service principal ID for a given service principal name.
    .DESCRIPTION
    This script retrieves the service principal ID using Azure CLI.
    .PARAMETER servicePrincipalName
    The name of the service principal for which the ID is to be retrieved.
    .EXAMPLE
    .\Get-ServicePrincipalId.ps1 -servicePrincipalName "MyServicePrincipal"
    Retrieves the ID of the specified service principal.
#>
function Get-ServicePrincipalId {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $servicePrincipalName
    )

    try {
        $servicePrincipal = az ad sp show --id $servicePrincipalName | ConvertFrom-Json
        return $servicePrincipal.id
    }
    catch {
        Write-Debug "Failed to get service principal ID: $_"
        return $null
    }
}

function Add-GroupToPowerBiWorkspace() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [guid]
        $groupId,

        [Parameter(Mandatory)]
        [guid]
        $workspaceId
    )
    try {
        # Add the service principal to the workspace.
        Add-PowerBIWorkspaceUser -Id $workspaceId -AccessRight Member -PrincipalType Group -Identifier $groupId
    }
    catch {
        $_.Exception.Message | Write-Debug
        Write-Debug "Failed to add group to Power BI workspace: $_"
    }
}

# Set up Service Principal in Azure AD Group
Add-ServicePrincipalToGroup -servicePrincipalId $servicePrincipalId -groupId $groupId
Get-ServicePrincipalMembers -groupId $groupId

# Set up Permissions for Power BI Service Principal
Install-Module -Name MicrosoftPowerBIMgmt -Scope CurrentUser -Force
Import-Module MicrosoftPowerBIMgmt

# Sign in to Power BI.
Login-PowerBI

Add-GroupToPowerBiWorkspace -groupId $groupId -workspaceId "f8b0c6d2-1e3a-4b5c-9f7d-2e3b1c4d5e6f" # My Food Bag BI workspace ID
Add-GroupToPowerBiWorkspace -groupId $groupId -workspaceId "7d69ade3-4b95-45c4-be98-935cc1acae1d" # Admin Data workspace ID
Add-GroupToPowerBiWorkspace -groupId $groupId -workspaceId "e2f7da46-00d6-43dc-acfb-6aa2918569a1" # 1.Growth workspace ID

# Get the workspace.
#Get-PowerBIWorkspace -Filter "name eq 'My Food Bag BI'"