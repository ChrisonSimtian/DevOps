<#
.SYNOPSIS
    Displays a spinner while executing a background task.
.DESCRIPTION
    This function shows a spinner animation in the console while a specified task is running in the background.
.PARAMETER Task
    A script block that contains the task to be executed in the background.
.PARAMETER TimeoutSeconds
    The maximum time in seconds to wait for the task to complete before timing out. Defaults to 10 seconds.
.PARAMETER Message
    A message to display while the spinner is active. Defaults to "Working".
.EXAMPLE
    # Example usage
    Show-Spinner -Task {
        Start-Sleep -Seconds 5
        "Finished background task"
    } -TimeoutSeconds 10 -Message "Processing"
#>
function Show-Spinner {
    param (
        [scriptblock]$Task,
        [int]$TimeoutSeconds = 10,
        [string]$Message = "Working"
    )

    $spinner = @('|', '/', '-', '\')
    $i = 0
    $startTime = Get-Date

    $job = Start-Job -ScriptBlock $Task

    Write-Host -NoNewline "$Message "

    while ($true) {
        if ($job.State -eq 'Completed') {
            break
        }

        if ((Get-Date) - $startTime -gt (New-TimeSpan -Seconds $TimeoutSeconds)) {
            Stop-Job $job
            Write-Host "`b❌ Timed out!"
            return
        }

        Write-Host -NoNewline "`b$($spinner[$i % $spinner.Length])"
        Start-Sleep -Milliseconds 100
        $i++
    }

    Receive-Job $job | Out-Null
    Remove-Job $job
    Write-Host "`b✅ Done!"
}