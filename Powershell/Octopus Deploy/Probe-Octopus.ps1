# Octopus 2019.10.12 API Probe (API v3.0)
# Validates connectivity, authentication, spaces, and key endpoints with pagination.

param(
    [Parameter(Mandatory=$true)][string]$OctopusUrl,             # e.g. https://octopus.company.local
    [Parameter(Mandatory=$true)][string]$ApiKey,                 # e.g. API-XXXX...
    [string]$SpaceName = "Default"                               # Change if your default space has a different name
)

$ErrorActionPreference = "Stop"

$Headers = @{
    "X-Octopus-ApiKey" = $ApiKey
    "Accept"            = "application/json"
}

function Invoke-Octo {
    param(
        [Parameter(Mandatory=$true)][string]$Uri,
        [ValidateSet('GET','POST','DELETE','PUT','PATCH')][string]$Method = 'GET'
    )
    Invoke-RestMethod -Uri $Uri -Headers $Headers -Method $Method
}

function Get-AllItems {
    param(
        [Parameter(Mandatory=$true)][string]$Uri
    )
    $results = @()
    $current = Invoke-Octo -Uri $Uri
    if ($current -is [array]) { return ,$current } # some endpoints return arrays directly

    while ($true) {
        if ($current.Items) { $results += $current.Items } elseif ($current -ne $null) { $results += $current }
        $next = $current.Links.'Page.Next'
        if ([string]::IsNullOrEmpty($next)) { break }
        $current = Invoke-Octo -Uri ($OctopusUrl + $next)
    }
    return $results
}

Write-Host "Probing API root..."
$root = Invoke-Octo -Uri "$OctopusUrl/api"
$serverVersion = $root.Version
$hasSpaces = $root.Links.ContainsKey('Spaces')
Write-Host "Server Version: $serverVersion"
Write-Host "Spaces Supported: $hasSpaces"

# Resolve space and set API base
$SpaceId = $null
if ($hasSpaces) {
    $spaces = Get-AllItems -Uri "$OctopusUrl/api/spaces"
    if (-not $spaces) { throw "No spaces returned; check permissions." }
    $space = $spaces | Where-Object { $_.Name -eq $SpaceName }
    if (-not $space) {
        Write-Warning "Space '$SpaceName' not found. Using first available space: '$($spaces[0].Name)'."
        $space = $spaces[0]
    }
    $SpaceId = $space.Id
    $ApiBase = "$OctopusUrl/api/$SpaceId"
    Write-Host "Using Space: $($space.Name) ($SpaceId)"
} else {
    $ApiBase = "$OctopusUrl/api"
    Write-Host "Using non-space-scoped API base."
}

function Test-Endpoint {
    param([Parameter(Mandatory=$true)][string]$Path,[string]$Label=$null)
    $label = $Label ?? $Path
    try {
        $items = Get-AllItems -Uri "$ApiBase/$Path"
        $count = ($items | Measure-Object).Count
        Write-Host ("✅ {0}: {1} item(s)" -f $label, $count)
        return @{ Ok = $true; Count = $count }
    } catch {
        Write-Warning ("❌ {0}: {1}" -f $label, $_.Exception.Message)
        return @{ Ok = $false; Error = $_.Exception.Message }
    }
}

Write-Host "`nTesting core resources..."
$projectsRes     = Test-Endpoint -Path "projects?skip=0&take=30" -Label "Projects (paged)"
$projectsAllRes  = Test-Endpoint -Path "projects/all" -Label "Projects (all)"
$envRes          = Test-Endpoint -Path "environments?skip=0&take=30" -Label "Environments (paged)"
$envAllRes       = Test-Endpoint -Path "environments/all" -Label "Environments (all)"
$releasesRes     = Test-Endpoint -Path "releases?skip=0&take=30" -Label "Releases (paged)"
$deploymentsRes  = Test-Endpoint -Path "deployments?skip=0&take=30" -Label "Deployments (paged)"
$tasksRes        = Test-Endpoint -Path "tasks?skip=0&take=30" -Label "Tasks (paged)"
$meRes = $null
try {
    $me = Invoke-Octo -Uri "$ApiBase/users/me"
    Write-Host "✅ Current user resolved: $($me.Username)"
    $meRes = @{ Ok = $true }
} catch {
    Write-Warning "❌ users/me: $($_.Exception.Message)"
    $meRes = @{ Ok = $false }
}

Write-Host "`nTesting serverstatus..."
try {
    $status = Invoke-Octo -Uri "$OctopusUrl/api/serverstatus"
    Write-Host "✅ Server status retrieved. Version: $($status.Version)"
} catch {
    Write-Warning "❌ serverstatus: $($_.Exception.Message)"
}

Write-Host "`nSummary:"
Write-Host ("- API Base: {0}" -f $ApiBase)
Write-Host ("- Projects available: {0}" -f ($projectsAllRes.Count ?? $projectsRes.Count))
Write-Host ("- Environments available: {0}" -f ($envAllRes.Count ?? $envRes.Count))
Write-Host ("- Releases (sample window): {0}" -f $releasesRes.Count)
Write-Host ("- Deployments (sample window): {0}" -f $deploymentsRes.Count)
Write-Host ("- Tasks (sample window): {0}" -f $tasksRes.Count)
Write-Host "Probe complete."