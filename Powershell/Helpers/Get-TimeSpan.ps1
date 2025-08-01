<#
.SYNOPSIS
    Converts an ISO 8601 duration string to a TimeSpan object.
.DESCRIPTION
    This function takes a duration string in ISO 8601 format (e.g., "PT30S" for 30 seconds)
    and converts it to a TimeSpan object.
.PARAMETER durationString
    The ISO 8601 duration string to convert.
.EXAMPLE
    $timeSpan = Get-TimeSpan -durationString "PT30S"
#>
function Get-TimeSpan {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $durationString
    )

    # Convert ISO 8601 duration string to TimeSpan
    if ($durationString -match "PT([\d\.]+)S") {
        $seconds = [double]$matches[1]
        $timeSpan = [TimeSpan]::FromSeconds($seconds)
        return $timeSpan
    }
}