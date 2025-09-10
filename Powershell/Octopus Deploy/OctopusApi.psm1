<#
.SYNOPSIS
    PowerShell helper module for Octopus Deploy 2019.10.12 (API v3.0)
.DESCRIPTION
    Provides functions to interact with Octopus API and invoke Octopus CLI.
    Includes JSON Schema export for deployment processes and variables.
.NOTES
    Author: Christian’s AI Copilot
    Version: 1.1
#>

# --- Module Variables ---
$script:OctopusUrl    = $null
$script:ApiKey        = $null
$script:SpaceId       = $null
$script:SpaceName     = $null
$script:ApiBase       = $null
$script:OctoCliPath   = $null
$script:Headers       = @{}

# --- Core Setup ---
function Connect-Octopus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][string]$ApiKey,
        [string]$SpaceName  = "Default",
        [string]$OctoCliPath
    )
    $script:OctopusUrl  = $Url.TrimEnd('/')
    $script:ApiKey      = $ApiKey
    $script:SpaceName   = $SpaceName
    $script:OctoCliPath = $OctoCliPath
    $script:Headers     = @{
        "X-Octopus-ApiKey" = $ApiKey
        "Accept"           = "application/json"
    }

    # Discover spaces
    $root      = Invoke-RestMethod -Uri "$OctopusUrl/api" -Headers $Headers
    $hasSpaces = $root.Links.ContainsKey('Spaces')

    if ($hasSpaces) {
        $spaces = Get-AllItems -Uri "$OctopusUrl/api/spaces"
        $space  = $spaces | Where-Object { $_.Name -eq $SpaceName }
        if (-not $space) {
            throw "Space '$SpaceName' not found. Available: $($spaces.Name -join ', ')"
        }
        $script:SpaceId = $space.Id
        $script:ApiBase = "$OctopusUrl/api/$($space.Id)"
    } else {
        $script:SpaceId = $null
        $script:ApiBase = "$OctopusUrl/api"
    }

    Write-Host "✅ Connected to $OctopusUrl (Space: $SpaceName)"
}

# --- Internal Helpers ---
function Invoke-Octo {
    param([Parameter(Mandatory)][string]$Uri)
    Invoke-RestMethod -Uri $Uri -Headers $script:Headers -Method GET
}

function Get-AllItems {
    param([Parameter(Mandatory)][string]$Uri)
    $results = @()
    $current = Invoke-Octo -Uri $Uri

    if ($current -is [array]) { return ,$current }

    while ($true) {
        if ($current.Items) { $results += $current.Items } else { $results += $current }
        $next = $current.Links.'Page.Next'
        if ([string]::IsNullOrEmpty($next)) { break }
        $current = Invoke-Octo -Uri ($script:OctopusUrl + $next)
    }

    return $results
}

# --- Core API Functions ---
function Get-OctoProjects      { Get-AllItems -Uri "$script:ApiBase/projects/all" }
function Get-OctoEnvironments  { Get-AllItems -Uri "$script:ApiBase/environments/all" }
function Get-OctoReleases      { param([string]$ProjectId) Get-AllItems -Uri "$script:ApiBase/projects/$ProjectId/releases?skip=0&take=50" }
function Get-OctoDeployments   { param([string]$ProjectId) Get-AllItems -Uri "$script:ApiBase/projects/$ProjectId/deployments?skip=0&take=50" }
function Get-OctoDeploymentProcess {
    param([string]$ProjectId)
    $proj   = Invoke-Octo -Uri "$script:ApiBase/projects/$ProjectId"
    $dpLink = $proj.Links.DeploymentProcess
    Invoke-Octo -Uri ($script:OctopusUrl + $dpLink)
}
function Get-OctoVariables {
    param([string]$ProjectId)
    $proj     = Invoke-Octo -Uri "$script:ApiBase/projects/$ProjectId"
    $varsLink = $proj.Links.Variables
    Invoke-Octo -Uri ($script:OctopusUrl + $varsLink)
}
function New-OctoDeployment {
    param(
        [string]$ProjectId,
        [string]$EnvironmentId,
        [string]$ReleaseVersion
    )
    $body = @{
        ProjectId      = $ProjectId
        EnvironmentId  = $EnvironmentId
        ReleaseVersion = $ReleaseVersion
    }
    Invoke-RestMethod -Uri "$script:ApiBase/deployments" `
        -Headers $script:Headers -Method POST `
        -Body ($body | ConvertTo-Json -Depth 5) -ContentType "application/json"
}
function Get-OctoServerStatus { Invoke-Octo -Uri "$script:OctopusUrl/api/serverstatus" }
function Get-OctoCurrentUser  { Invoke-Octo -Uri "$script:ApiBase/users/me" }

# --- JSON Schema Export ---
function Export-OctoDeploymentProcessSchema {
    param(
        [Parameter(Mandatory)][string]$ProjectId,
        [string]$OutDir = $PSScriptRoot
    )
    $dp = Get-OctoDeploymentProcess -ProjectId $ProjectId
    if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

    $jsonPath   = Join-Path $OutDir "deployment-process-$ProjectId.json"
    $schemaPath = Join-Path $OutDir "deployment-process-$ProjectId.schema.json"

    $dp | ConvertTo-Json -Depth 100 | Out-File -FilePath $jsonPath -Encoding UTF8
    Write-Host "Saved JSON: $jsonPath"

    # Recursive schema inference
    function Get-JsonType { param($v) switch ($v.GetType().Name) {
        'String'      {'string'}; 'Int32'{'integer'}; 'Int64'{'integer'};
        'Double'      {'number'}; 'Decimal'{'number'}; 'Boolean'{'boolean'};
        'DateTime'    {'string'}; 'Guid'{'string'}; 'Object[]'{'array'};
        'Hashtable'   {'object'}; 'PSCustomObject'{'object'} default{'object'}
    }}
    function To-Schema {
        param($node)
        $t = Get-JsonType -v $node
        $s = [ordered]@{ type = $t }
        if ($t -eq 'object') {
            $props    = [ordered]@{}; $req = @()
            foreach ($p in $node.PSObject.Properties) {
                $props[$p.Name] = To-Schema -node $p.Value
                if ($p.Value -ne $null) { $req += $p.Name }
            }
            $s.properties = $props
            if ($req) { $s.required = $req }
        } elseif ($t -eq 'array') {
            if ($node.Count -gt 0) { $s.items = To-Schema -node $node[0] }
            else { $s.items = @{} }
        }
        return $s
    }

    $base = To-Schema -node $dp
    $schema = [ordered]@{
        '$schema'    = 'http://json-schema.org/draft-07/schema#'
        'title'      = "Deployment Process ($ProjectId)"
        'type'       = 'object'
        'properties' = $base.properties
        'required'   = $base.required
    }
    $schema | ConvertTo-Json -Depth 100 | Out-File -FilePath $schemaPath -Encoding UTF8
    Write-Host "Saved JSON Schema: $schemaPath"
}

function Export-OctoVariablesSchema {
    param(
        [Parameter(Mandatory)][string]$ProjectId,
        [string]$OutDir = $PSScriptRoot
    )
    $vars = Get-OctoVariables -ProjectId $ProjectId
    if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

    $jsonPath   = Join-Path $OutDir "variables-$ProjectId.json"
    $schemaPath = Join-Path $OutDir "variables-$ProjectId.schema.json"

    $vars | ConvertTo-Json -Depth 100 | Out-File -FilePath $jsonPath -Encoding UTF8
    Write-Host "Saved JSON: $jsonPath"

    # Reuse schema inference from deployment process
    $sDef = Export-OctoDeploymentProcessSchema -ProjectId $ProjectId -OutDir $OutDir
    # Adjust title for variables
    (Get-Content $schemaPath | ConvertFrom-Json).title = "Variables ($ProjectId)" |
        ConvertTo-Json -Depth 100 | Out-File -FilePath $schemaPath -Encoding UTF8
    Write-Host "Saved JSON Schema: $schemaPath"
}

# --- Octopus CLI Integration ---
function Invoke-OctoCli {
    param([Parameter(Mandatory)][string[]]$Arguments)
    if (-not $script:OctoCliPath) {
        throw "Octo CLI path not set. Supply -OctoCliPath to Connect-Octopus."
    }
    & $script:OctoCliPath @Arguments
}

function Get-OctoCliProjects {
    Invoke-OctoCli -Arguments @("list-projects","--server",$script:OctopusUrl,"--apiKey",$script:ApiKey,"--space",$script:SpaceName)
}
function Get-OctoCliEnvironments {
    Invoke-OctoCli -Arguments @("list-environments","--server",$script:OctopusUrl,"--apiKey",$script:ApiKey,"--space",$script:SpaceName)
}
function Get-OctoCliReleases {
    param([string]$ProjectName)
    Invoke-OctoCli -Arguments @("list-releases","--project",$ProjectName,"--server",$script:OctopusUrl,"--apiKey",$script:ApiKey,"--space",$script:SpaceName)
}
function Create-OctoCliRelease {
    param(
        [string]$ProjectName,
        [string]$ReleaseNumber
    )
    Invoke-OctoCli -Arguments @("create-release","--project",$ProjectName,"--releaseNumber",$ReleaseNumber,"--server",$script:OctopusUrl,"--apiKey",$script:ApiKey,"--space",$script:SpaceName)
}
function Deploy-OctoCliRelease {
    param(
        [string]$ProjectName,
        [string]$ReleaseNumber,
        [string]$EnvironmentName
    )
    Invoke-OctoCli -Arguments @("deploy-release","--project",$ProjectName,"--releaseNumber",$ReleaseNumber,"--deployTo",$EnvironmentName,"--server",$script:OctopusUrl,"--apiKey",$script:ApiKey,"--space",$script:SpaceName)
}
function Get-OctoCliTasks {
    Invoke-OctoCli -Arguments @("list-tasks","--server",$script:OctopusUrl,"--apiKey",$script:ApiKey,"--space",$script:SpaceName)
}
function Get-OctoCliServerStatus {
    Invoke-OctoCli -Arguments @("serverstatus","--server",$script:OctopusUrl,"--apiKey",$script:ApiKey)
}
function Get-OctoCliCurrentUser {
    Invoke-OctoCli -Arguments @("whoami","--server",$script:OctopusUrl,"--apiKey",$script:ApiKey,"--space",$script:SpaceName)
}

Export-ModuleMember -Function *-Octo*
# Example usage:
# Connect-Octopus -Url "https://your-octopus-url" -ApiKey "API-XXXX" -SpaceName "Default" -OctoCliPath "C:\path\to\octo.exe"