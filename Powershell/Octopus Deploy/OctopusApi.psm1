<#
.SYNOPSIS
    PowerShell helper module for Octopus Deploy 2019.10.12 (API v3.0)
.DESCRIPTION
    Provides functions to interact with common Octopus API endpoints in a space-aware way.
    Handles authentication, pagination, and link-following.
.NOTES
    Author: Christian's AI Copilot
    Version: 1.0
#>

# --- Module Variables ---
$script:OctopusUrl = $null
$script:ApiKey     = $null
$script:SpaceId    = $null
$script:ApiBase    = $null
$script:Headers    = @{}

# --- Core Setup ---
function Connect-Octopus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][string]$ApiKey,
        [string]$SpaceName = "Default"
    )
    $script:OctopusUrl = $Url.TrimEnd('/')
    $script:ApiKey     = $ApiKey
    $script:Headers    = @{
        "X-Octopus-ApiKey" = $ApiKey
        "Accept"           = "application/json"
    }

    $root = Invoke-RestMethod -Uri "$OctopusUrl/api" -Headers $Headers
    $hasSpaces = $root.Links.ContainsKey('Spaces')

    if ($hasSpaces) {
        $spaces = Get-AllItems "$OctopusUrl/api/spaces"
        $space  = $spaces | Where-Object { $_.Name -eq $SpaceName }
        if (-not $space) {
            throw "Space '$SpaceName' not found. Available: $($spaces.Name -join ', ')"
        }
        $script:SpaceId = $space.Id
        $script:ApiBase = "$OctopusUrl/api/$SpaceId"
    } else {
        $script:SpaceId = $null
        $script:ApiBase = "$OctopusUrl/api"
    }

    Write-Host "✅ Connected to Octopus at $OctopusUrl (Space: $SpaceName)"
}

# --- Internal Helpers ---
function Invoke-Octo {
    param([string]$Uri)
    Invoke-RestMethod -Uri $Uri -Headers $script:Headers -Method GET
}

function Get-AllItems {
    param([string]$Uri)
    $results = @()
    $current = Invoke-Octo $Uri
    if ($current -is [array]) { return ,$current }
    while ($true) {
        if ($current.Items) { $results += $current.Items } else { $results += $current }
        $next = $current.Links.'Page.Next'
        if ([string]::IsNullOrEmpty($next)) { break }
        $current = Invoke-Octo ($script:OctopusUrl + $next)
    }
    return $results
}

# --- Public API Functions ---
function Get-OctoProjects {
    Get-AllItems "$script:ApiBase/projects/all"
}

function Get-OctoEnvironments {
    Get-AllItems "$script:ApiBase/environments/all"
}

function Get-OctoReleases {
    param([Parameter(Mandatory)][string]$ProjectId)
    Get-AllItems "$script:ApiBase/projects/$ProjectId/releases?skip=0&take=50"
}

function Get-OctoDeployments {
    param([Parameter(Mandatory)][string]$ProjectId)
    Get-AllItems "$script:ApiBase/projects/$ProjectId/deployments?skip=0&take=50"
}

function Get-OctoDeploymentProcess {
    param([Parameter(Mandatory)][string]$ProjectId)
    $project = Invoke-Octo "$script:ApiBase/projects/$ProjectId"
    $dpLink  = $project.Links.DeploymentProcess
    Invoke-Octo ($script:OctopusUrl + $dpLink)
}

function Get-OctoVariables {
    param([Parameter(Mandatory)][string]$ProjectId)
    $project = Invoke-Octo "$script:ApiBase/projects/$ProjectId"
    $varsLink = $project.Links.Variables
    Invoke-Octo ($script:OctopusUrl + $varsLink)
}

function New-OctoDeployment {
    param(
        [Parameter(Mandatory)][string]$ProjectId,
        [Parameter(Mandatory)][string]$EnvironmentId,
        [Parameter(Mandatory)][string]$ReleaseVersion
    )
    $body = @{
        ProjectId      = $ProjectId
        EnvironmentId  = $EnvironmentId
        ReleaseVersion = $ReleaseVersion
    }
    Invoke-RestMethod -Uri "$script:ApiBase/deployments" -Headers $script:Headers -Method POST -Body ($body | ConvertTo-Json -Depth 5) -ContentType "application/json"
}

function Get-OctoServerStatus {
    Invoke-Octo "$script:OctopusUrl/api/serverstatus"
}

function Get-OctoCurrentUser {
    Invoke-Octo "$script:ApiBase/users/me"
}

Export-ModuleMember -Function *-Octo*
