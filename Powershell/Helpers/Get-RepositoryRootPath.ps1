<#
.SYNOPSIS
    Retrieves the root path of a repository based on a specified folder name.
.DESCRIPTION
    This function searches for a specified folder name in the directory hierarchy starting from the current script's path.
.PARAMETER repositoryFolderName
    The name of the repository folder to search for.
.PARAMETER currentPath
    The path from which to start the search. Defaults to the script's current path.
.EXAMPLE
    Get-RepositoryRootPath -repositoryFolderName "myfoodbag.erp"
#>
function Get-RepositoryRootPath {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $repositoryFolderName,
        [Parameter()]
        [string]
        $currentPath = $PSScriptRoot
    )
    Write-Debug "🔄 Searching for repository root folder '$repositoryFolderName'..."

    # resolve path of this repository
    $repositoryPath = ""
    $currentPath = $PSScriptRoot

    # Start from current directory and traverse up to find the repository root
    $searchPath = $currentPath
    while ($searchPath -and (Split-Path $searchPath -Leaf) -ne $repositoryFolderName) {
        $parentPath = Split-Path $searchPath -Parent
        if ($parentPath -eq $searchPath) {
            # Reached the root without finding the repository folder
            $searchPath = $null
            break
        }
        $searchPath = $parentPath
    }

    if ($searchPath) {
        $repositoryPath = $searchPath
        Write-Information "✅ Repository root found: $repositoryPath"
        return $repositoryPath
    }
    else {
        Write-Error "🔴 Repository folder '$repositoryFolderName' not found in the directory hierarchy."
        throw "❌ Could not locate repository root directory."
    }
}