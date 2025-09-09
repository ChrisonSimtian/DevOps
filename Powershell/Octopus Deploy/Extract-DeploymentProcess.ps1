# Octopus 2019.10.12 Deployment Process Extractor + JSON Schema inference

param(
    [Parameter(Mandatory=$true)][string]$OctopusUrl,
    [Parameter(Mandatory=$true)][string]$ApiKey,
    [Parameter(Mandatory=$true)][string]$ProjectName,
    [string]$SpaceName = "Default",
    [string]$OutDir = "$PSScriptRoot"
)

$ErrorActionPreference = "Stop"

$Headers = @{
    "X-Octopus-ApiKey" = $ApiKey
    "Accept"            = "application/json"
}

function Invoke-Octo {
    param([Parameter(Mandatory=$true)][string]$Uri,[string]$Method='GET')
    Invoke-RestMethod -Uri $Uri -Headers $Headers -Method $Method
}

function Get-AllItems {
    param([Parameter(Mandatory=$true)][string]$Uri)
    $results = @()
    $current = Invoke-Octo -Uri $Uri
    if ($current -is [array]) { return ,$current }
    while ($true) {
        if ($current.Items) { $results += $current.Items } elseif ($current -ne $null) { $results += $current }
        $next = $current.Links.'Page.Next'
        if ([string]::IsNullOrEmpty($next)) { break }
        $current = Invoke-Octo -Uri ($OctopusUrl + $next)
    }
    return $results
}

# Resolve API base with spaces
$root = Invoke-Octo -Uri "$OctopusUrl/api"
$hasSpaces = $root.Links.ContainsKey('Spaces')

if ($hasSpaces) {
    $spaces = Get-AllItems -Uri "$OctopusUrl/api/spaces"
    $space = $spaces | Where-Object { $_.Name -eq $SpaceName }
    if (-not $space) {
        throw "Space '$SpaceName' not found. Available: $($spaces.Name -join ', ')"
    }
    $SpaceId = $space.Id
    $ApiBase = "$OctopusUrl/api/$SpaceId"
} else {
    $ApiBase = "$OctopusUrl/api"
    $SpaceId = $null
}

# Resolve project
$projects = Get-AllItems -Uri "$ApiBase/projects/all"
$project = $projects | Where-Object { $_.Name -eq $ProjectName }
if (-not $project) {
    throw "Project '$ProjectName' not found in space '$SpaceName'."
}

# Follow the canonical link to the deployment process
$dpLink = $project.Links.DeploymentProcess
if ([string]::IsNullOrEmpty($dpLink)) {
    throw "Project does not expose Links.DeploymentProcess. Check permissions."
}
# dpLink is typically a relative path like /api/{spaceId}/deploymentprocesses/deploymentprocess-{guid}
$dpUri = if ($dpLink -like "http*") { $dpLink } else { "$OctopusUrl$dpLink" }

$deploymentProcess = Invoke-Octo -Uri $dpUri

# Ensure output directory
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

$dpOut = Join-Path $OutDir "deployment-process-$($project.Id).json"
$deploymentProcess | ConvertTo-Json -Depth 100 | Out-File -FilePath $dpOut -Encoding UTF8
Write-Host "✅ Saved deployment process: $dpOut"

# Minimal recursive JSON Schema inference (Draft-07-like)
function Get-JsonType {
    param($value)
    switch ($value.GetType().Name) {
        'String'       { 'string'; break }
        'Int32'        { 'integer'; break }
        'Int64'        { 'integer'; break }
        'Double'       { 'number'; break }
        'Decimal'      { 'number'; break }
        'Boolean'      { 'boolean'; break }
        'DateTime'     { 'string' ; break }
        'Guid'         { 'string' ; break }
        'Hashtable'    { 'object' ; break }
        'PSCustomObject' { 'object'; break }
        'Object[]'     { 'array'  ; break }
        default        { 'object' }
    }
}

function To-Schema {
    param($node)
    $type = Get-JsonType -value $node
    $schema = [ordered]@{ type = $type }

    if ($type -eq 'object') {
        $props = [ordered]@{}
        $required = @()
        $node.PSObject.Properties | ForEach-Object {
            $props[$_.Name] = To-Schema -node $_.Value
            if ($_.Value -ne $null) { $required += $_.Name }
        }
        $schema.properties = $props
        if ($required.Count -gt 0) { $schema.required = $required }
    } elseif ($type -eq 'array') {
        if ($node.Count -gt 0) {
            # Union types are possible; we take the first element as representative
            $schema.items = To-Schema -node $node[0]
        } else {
            $schema.items = @{ }
        }
    } elseif ($type -eq 'string' -and ($node -is [DateTime])) {
        $schema.format = 'date-time'
    }

    return $schema
}

$schema = [ordered]@{
    '$schema' = 'http://json-schema.org/draft-07/schema#'
    'title'   = "Octopus Deployment Process ($($project.Name))"
    'type'    = 'object'
    'properties' = (To-Schema -node $deploymentProcess).properties
    'required'   = (To-Schema -node $deploymentProcess).required
}

$schemaOut = Join-Path $OutDir "deployment-process-$($project.Id).schema.json"
$schema | ConvertTo-Json -Depth 100 | Out-File -FilePath $schemaOut -Encoding UTF8
Write-Host "✅ Saved inferred schema: $schemaOut"

# Bonus: export variables and releases (optional scaffolding for your extension)
try {
    $varsLink = $project.Links.Variables
    if ($varsLink) {
        $varsUri = if ($varsLink -like "http*") { $varsLink } else { "$OctopusUrl$varsLink" }
        $vars = Invoke-Octo -Uri $varsUri
        $varsOut = Join-Path $OutDir "variables-$($project.Id).json"
        $vars | ConvertTo-Json -Depth 100 | Out-File -FilePath $varsOut -Encoding UTF8
        Write-Host "✅ Saved variables: $varsOut"
    }
} catch {
    Write-Warning "Variables export failed: $($_.Exception.Message)"
}

try {
    $releases = Get-AllItems -Uri "$ApiBase/projects/$($project.Id)/releases?skip=0&take=50"
    $relOut = Join-Path $OutDir "releases-$($project.Id).json"
    $releases | ConvertTo-Json -Depth 100 | Out-File -FilePath $relOut -Encoding UTF8
    Write-Host "✅ Saved recent releases: $relOut"
} catch {
    Write-Warning "Releases export failed: $($_.Exception.Message)"
}
