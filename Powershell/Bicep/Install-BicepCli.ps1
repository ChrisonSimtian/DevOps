<#
.SYNOPSIS
    Installs the Bicep CLI if it is not already installed.
.DESCRIPTION
    This function checks if the Bicep CLI is installed. If not, it downloads and installs it to the specified path.
.PARAMETER installPath
    The path where the Bicep CLI will be installed. Defaults to "$env:USERPROFILE\.bicep".
.PARAMETER addToPath
    Whether to add the Bicep CLI to the system PATH. Defaults to false.
.EXAMPLE
    Install-BicepCli -installPath "C:\Tools\Bicep"
#>
function Install-BicepCli {

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $installPath = "$env:USERPROFILE\.bicep", # Default installation path
        [Parameter()]
        [switch]
        $addToPath = $false # Whether to add Bicep CLI to PATH
    )

    Write-Information "🔄 Checking for Bicep CLI..."
    
    # Check if Bicep is already available
    try {
        $bicepVersion = bicep --version
        Write-Information "✅ Bicep CLI is already installed: $bicepVersion"
        return
    }
    catch {
        Write-Information "❌ Bicep CLI not found. Installing..."
    }
    
    # Install Bicep CLI using PowerShell
    try {
        # Download and install Bicep CLI
        $bicepPath = "$installPath\bicep.exe"
        
        if (-not (Test-Path $installPath)) {
            New-Item -ItemType Directory -Path $installPath -Force | Out-Null
        }
        
        # Download the latest Bicep CLI
        $uri = "https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe"
        Write-Information "📥 Downloading Bicep CLI from $uri"
        Invoke-WebRequest -Uri $uri -OutFile $bicepPath
        
        # Add to PATH for current session
        $env:PATH = "$installPath;$env:PATH"
        
        # Verify installation
        $bicepVersion = & $bicepPath --version
        Write-Information "✅ Bicep CLI installed successfully: $bicepVersion"
        
        # Add to user PATH permanently
        if($addToPath) {
            $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
            if ($userPath -notlike "*$installPath*") {
                [Environment]::SetEnvironmentVariable("PATH", "$userPath;$installPath", "User")
                Write-Information "✅ Added Bicep to user PATH"
            } else {
                Write-Information "☑️ Bicep CLI is already in user PATH."
            }
        }
    }
    catch {
        Write-Error "❌ Failed to install Bicep CLI: $_"
        throw
    }
}