# $servicePrincipalId = "8a83567d-41cf-4d68-999f-3c3e94eff862" # prod service principal ID
$servicePrincipalId = "62fdad3e-643c-493d-bad2-561b89b8b378" # test service principal ID
# 62fdad3e-643c-493d-bad2-561b89b8b378
$groupName = "Users | Access | Power BI | Fabric Public API Calls Allowed"

try {
    az ad group member add --group $groupName --member-id $servicePrincipalId
}
catch {
    Write-Debug "Failed to add service principal to group: $_"
}

$groupId = az ad group show -g $groupName --query id -o tsv
az rest --method get --url "https://graph.microsoft.com/beta/groups/$groupId/members"  | jq -r ".value | .[] | [.displayName,.id] | @tsv"