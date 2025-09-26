# Define your media folder path
$mediaPath = "\\192.168.179.11\Volume-3\data\media"  # Change this to your actual media folder
$videoExtensions = @(
    "*.mov", 
    "*.wmv", 
    "*.flv", 
    "*.f4v", 
    "*.webm", 
    "*.ts", 
    "*.m2ts", 
    "*.vob", 
    "*.ogv", 
    "*.3gp",
    "*.mkv", 
    "*.mp4", 
    "*.avi")
$ffprobePath = Join-Path $PSScriptRoot '..\..\Tools\ffmpeg\bin\ffprobe.exe'
if (-not (Test-Path $ffprobePath)) { throw "ffprobe not found at $ffprobePath" }


# Initialize counters
$h264Count = 0
$hevcCount = 0
$otherCount = 0

# Get all video files
$videoFiles = Get-ChildItem -Path $mediaPath -Recurse -File -Include $videoExtensions
$totalFiles = $videoFiles.Count
$index = 0
Write-Host "Found $totalFiles video files. Starting analysis..."

foreach ($file in $videoFiles) {
    $index++

    # Update progress bar
    $percentComplete = [math]::Round(($index / $totalFiles) * 100, 2)
    Write-Progress -Activity "Scanning media files..." `
        -Status "Processing $($file.FullName) - $index of $totalFiles ($percentComplete%)" `
        -PercentComplete $percentComplete

    # Get codec information using ffprobe
    $ffprobeOutput = & $ffprobePath -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$($file.FullName)"
    
    switch ($ffprobeOutput.Trim()) {
        "h264" { $h264Count++ }
        "hevc" { $hevcCount++ }
        default { $otherCount++ }
    }
}
Write-Progress -Activity "Scanning media files..." -Completed

# Output results
Write-Host "📊 Media Codec Summary:"
Write-Host "H.264 files: $h264Count"
Write-Host "HEVC (H.265) files: $hevcCount"
Write-Host "Other codecs: $otherCount"
Write-Host "Total files scanned: $($videoFiles.Count)"
