Install-Module -Name MicrosoftPowerBIMgmt -Scope CurrentUser -Force
Import-Module MicrosoftPowerBIMgmt
# Sign in to Power BI.
Login-PowerBI

# $servicePrincipalId = "8a83567d-41cf-4d68-999f-3c3e94eff862" # prod service principal ID
$servicePrincipalId = "62fdad3e-643c-493d-bad2-561b89b8b378" # test service principal ID

# Get the workspace.
$pbiWorkspace = Get-PowerBIWorkspace -Filter "name eq 'My Food Bag BI'"

# Add the service principal to the workspace.
Add-PowerBIWorkspaceUser -Id $($pbiWorkspace.Id) -AccessRight Member -PrincipalType Group -Identifier $($servicePrincipalId)