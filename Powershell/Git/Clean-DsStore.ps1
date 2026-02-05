<#
.SYNOPSIS
  Removes tracked .DS_Store files from a Git repository and prevents re-adding via .gitignore.

.DESCRIPTION
  - Adds .DS_Store ignore rules to .gitignore (creates file if missing)
  - Removes tracked .DS_Store files from Git index (git rm --cached)
  - Optionally deletes local .DS_Store files on disk
  - Optionally commits and pushes changes

.PARAMETER RepoPath
  Path to the repository root (defaults to current directory)

.PARAMETER Commit
  If set, creates a commit with the changes

.PARAMETER Push
  If set, pushes after committing (implies -Commit)

.PARAMETER CommitMessage
  Commit message to use if -Commit or -Push

.PARAMETER RemoveLocalFiles
  If set, deletes .DS_Store files from the working tree (disk)

.PARAMETER WhatIf
  Shows what would happen without making changes (PowerShell built-in)

.EXAMPLE
  .\Clean-DsStore.ps1 -RepoPath C:\src\myrepo -Commit -Push

.EXAMPLE
  .\Clean-DsStore.ps1 -RemoveLocalFiles -Commit -CommitMessage "Cleanup macOS metadata"
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [Parameter(Position=0)]
  [string]$RepoPath = (Get-Location).Path,

  [switch]$Commit,

  [switch]$Push,

  [string]$CommitMessage = "Remove .DS_Store files and ignore them",

  [switch]$RemoveLocalFiles
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-GitAvailable {
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git is not available on PATH. Install Git for Windows or ensure 'git' is on PATH."
  }
}

function Assert-IsGitRepo([string]$Path) {
  Push-Location $Path
  try {
    $isRepo = git rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0 -or $isRepo -ne "true") {
      throw "Path '$Path' is not a Git repository (or not inside one)."
    }
  } finally {
    Pop-Location
  }
}

function Ensure-GitIgnoreRules([string]$Path) {
  $gitIgnorePath = Join-Path $Path ".gitignore"
  $rulesToAdd = @(
    "# macOS Finder metadata",
    ".DS_Store",
    "**/.DS_Store"
  )

  if (-not (Test-Path $gitIgnorePath)) {
    if ($PSCmdlet.ShouldProcess($gitIgnorePath, "Create .gitignore and add .DS_Store rules")) {
      $rulesToAdd | Set-Content -Path $gitIgnorePath -Encoding UTF8
      Write-Host "Created .gitignore with .DS_Store rules." -ForegroundColor Green
    }
    return
  }

  $existing = Get-Content -Path $gitIgnorePath -Raw
  $missing = @()

  foreach ($rule in $rulesToAdd) {
    # Only treat actual ignore rules as required; comment line is optional
    if ($rule -notmatch '^#' -and $existing -notmatch "(?m)^\Q$rule\E\s*$") {
      $missing += $rule
    }
  }

  if ($missing.Count -gt 0) {
    if ($PSCmdlet.ShouldProcess($gitIgnorePath, "Append missing .DS_Store rules to .gitignore")) {
      Add-Content -Path $gitIgnorePath -Value ""
      Add-Content -Path $gitIgnorePath -Value $rulesToAdd[0]
      $missing | ForEach-Object { Add-Content -Path $gitIgnorePath -Value $_ }
      Write-Host "Appended missing .DS_Store rules to .gitignore: $($missing -join ', ')" -ForegroundColor Green
    }
  } else {
    Write-Host ".gitignore already contains .DS_Store rules." -ForegroundColor DarkGreen
  }
}

function Remove-TrackedDsStore([string]$Path) {
  Push-Location $Path
  try {
    # Find tracked DS_Store files
    $tracked = git ls-files | Where-Object { $_ -match '(^|/)\.DS_Store$' }

    if (-not $tracked -or $tracked.Count -eq 0) {
      Write-Host "No tracked .DS_Store files found." -ForegroundColor DarkGreen
      return
    }

    Write-Host "Tracked .DS_Store files found: $($tracked.Count)" -ForegroundColor Yellow

    foreach ($file in $tracked) {
      if ($PSCmdlet.ShouldProcess($file, "git rm --cached")) {
        git rm --cached --ignore-unmatch -- "$file" | Out-Null
      }
    }

    Write-Host "Removed tracked .DS_Store files from Git index." -ForegroundColor Green
  } finally {
    Pop-Location
  }
}

function Remove-LocalDsStoreFiles([string]$Path) {
  $files = Get-ChildItem -Path $Path -Filter ".DS_Store" -File -Recurse -Force -ErrorAction SilentlyContinue
  if (-not $files -or $files.Count -eq 0) {
    Write-Host "No local .DS_Store files found on disk." -ForegroundColor DarkGreen
    return
  }

  Write-Host "Local .DS_Store files found on disk: $($files.Count)" -ForegroundColor Yellow
  foreach ($f in $files) {
    if ($PSCmdlet.ShouldProcess($f.FullName, "Delete file")) {
      Remove-Item -LiteralPath $f.FullName -Force
    }
  }
  Write-Host "Deleted local .DS_Store files." -ForegroundColor Green
}

function Commit-AndMaybePush([string]$Path, [string]$Message, [bool]$DoPush) {
  Push-Location $Path
  try {
    # Stage .gitignore changes and index removals
    if ($PSCmdlet.ShouldProcess($Path, "git add .gitignore")) {
      git add .gitignore | Out-Null
    }

    # Only commit if there are staged changes
    $status = git status --porcelain
    if (-not $status) {
      Write-Host "No changes to commit." -ForegroundColor DarkGreen
      return
    }

    if ($PSCmdlet.ShouldProcess($Path, "git commit")) {
      git commit -m "$Message" | Out-Null
      Write-Host "Committed changes: $Message" -ForegroundColor Green
    }

    if ($DoPush) {
      if ($PSCmdlet.ShouldProcess($Path, "git push")) {
        git push | Out-Null
        Write-Host "Pushed changes." -ForegroundColor Green
      }
    }
  } finally {
    Pop-Location
  }
}

# ----- Main -----

Assert-GitAvailable
Assert-IsGitRepo $RepoPath

# Push implies commit
if ($Push) { $Commit = $true }

Write-Host "Cleaning .DS_Store in repo: $RepoPath" -ForegroundColor Cyan

Ensure-GitIgnoreRules $RepoPath
Remove-TrackedDsStore $RepoPath

if ($RemoveLocalFiles) {
  Remove-LocalDsStoreFiles $RepoPath
}

if ($Commit) {
  Commit-AndMaybePush $RepoPath $CommitMessage $Push.IsPresent
} else {
  Write-Host "Done. (No commit requested)" -ForegroundColor Cyan
  Write-Host "Tip: run with -Commit (and optionally -Push) to finish automatically." -ForegroundColor DarkCyan
}