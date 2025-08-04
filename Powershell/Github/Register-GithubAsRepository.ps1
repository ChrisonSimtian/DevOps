function Register-GithubAsRepository {
  param (
    [Parameter(Mandatory)]
    [string]
    $Token,
    [Parameter(Mandatory)]
    [string]
    $RepositoryName
  )
  #Requires -Version 7.0
  #Requires -Module Microsoft.PowerShell.PSResourceGet
  # Register the GitHub repository as a PowerShell repository
  Register-PSRepository -Name $RepositoryName `
    -SourceLocation "https://nuget.pkg.github.com/$owner/index.json" ` # This is the source location for the repository
    -PublishLocation "https://nuget.pkg.github.com/$owner/index.json" ` # This is the publish location for the module
    -InstallationPolicy Trusted
  Write-Information "Repository '$RepositoryName' registered successfully."
}