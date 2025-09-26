# Define network path and drive letter
$networkPath = Read-Host "Enter network path (e.g. \\server\share)"
$driveLetter = Read-Host "Enter drive letter (e.g. X:)"
$username = Read-Host "Enter username"
$password = Read-Host "Enter password" -AsSecureString

# Disconnect any existing connections to the server
$serverRoot = ($networkPath -split '\\')[2]
net use $serverRoot /delete /yes 2>$null

$credential = New-Object System.Management.Automation.PSCredential ($username, $password)

# Map the drive
New-PSDrive -Name $driveLetter.TrimEnd(':') -PSProvider FileSystem -Root $networkPath -Credential $credential -Persist
Write-Host "Mapped $networkPath to drive $driveLetter"