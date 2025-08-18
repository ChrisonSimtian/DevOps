function Get-FolderContent {
    Write-Output "File Structure"
    Get-ChildItem -File | ForEach-Object { Write-Output $_.FullName }
}