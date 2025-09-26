# Forcefully remove mapped drive Z: even if it's disconnected or unreachable
$driveLetter = "Z:"
if (Test-Path $driveLetter) {
    Remove-PSDrive -Name $driveLetter -Force
} else {
    net use $driveLetter /delete /yes
}