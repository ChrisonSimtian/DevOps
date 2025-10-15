#Requires -Module Az.Accounts, Az.Resources

# Workaround for 'Assembly with same name is already loaded' error
# Remove the module if already loaded, then import again
if (Get-Module -ListAvailable -Name Az.Accounts) {
    Remove-Module Az.Accounts -ErrorAction SilentlyContinue
}
if (Get-Module -ListAvailable -Name Az.Resources) {
    Remove-Module Az.Resources -ErrorAction SilentlyContinue
}
Import-Module Az.Accounts -Force
Import-Module Az.Resources -Force

# Ensure you are logged in to Azure
Connect-AzAccount

# Replace with your managed identity's Object ID (GUID)
$objectId = "f70f6ca2-6d9f-4f87-a720-d752d2504c29"

# Get the managed identity from Azure AD
$identity = Get-AzADServicePrincipal -ObjectId $objectId

# Display the identity details
if ($identity) {
    $identity | Format-List DisplayName, Id, AppId, ObjectId
} else {
    Write-Host "Managed Identity with Object ID $objectId not found."
}
