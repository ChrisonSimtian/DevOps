function Publish-PowershellModule {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory)]
      [string]
      $Token,
      [Parameter(Mandatory)]
      [string]
      $RepositoryName,
      [Parameter(Mandatory)]
      [string]
      $ModulePath
  )

  Write-Debug "Starting module publication process..."
  # Validate the token
  if (-not $Token) {
      Write-Error "Token is required for publishing the module."
      throw "Token not provided"
  }

  # Validate ModulePath
  if (-not (Test-Path -Path $ModulePath)) {
      Write-Error "Module path '$ModulePath' does not exist. Please provide a valid module path."
      throw "Module path not found"
  }

  # Ensure the repository is registered
  if (-not (Get-PSRepository -Name $RepositoryName -ErrorAction SilentlyContinue)) {
      Write-Error "Repository '$RepositoryName' is not registered. Please register it first."
      throw "Repository not registered"
  }

  # Ensure the module path contains the necessary files
  if (-not (Get-ChildItem -Path $ModulePath -Filter "*.psm1" -ErrorAction SilentlyContinue)) {
      Write-Error "Module file 'Module.psm1' not found in path '$ModulePath'."
      throw "Module file not found"
  }

  # Ensure the module manifest exists
  if (-not (Get-ChildItem -Path $ModulePath -Filter "*.psd1" -ErrorAction SilentlyContinue)) {
      Write-Error "Module manifest file 'Module.psd1' not found in path '$ModulePath'."
      throw "Module manifest not found"
  }
  Set-Location -Path $ModulePath

  # Publish the module to the specified repository
  Write-Debug "Publishing module to repository '$RepositoryName'..."
  Publish-Module `
    -Path $ModulePath `
    -Repository $RepositoryName `
    -NuGetApiKey $Token
  Write-Information "Module published successfully to '$RepositoryName'."
}