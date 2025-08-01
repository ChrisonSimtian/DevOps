# This script lists all service principals in a specific Azure AD group using Azure CLI and jq for JSON processing.

# Define the Azure AD group GUID - change this value for different groups
$groupId = "8e1449e1-2627-40c2-a88e-07604f79c862"

# Get all service principals in the specified group with proper query syntax
# Uses Azure CLI to query Microsoft Graph API
az rest --method get --url "https://graph.microsoft.com/beta/groups/$groupId/members"  | jq -r ".value | .[] | [.displayName,.id] | @tsv"