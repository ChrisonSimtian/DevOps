<#
.SYNOPSIS
    Capitalizes the first letter of a string.
.DESCRIPTION
    This function takes a string input and returns the same string with the first letter capitalized.
.PARAMETER word
    The input string to be capitalized.
.EXAMPLE
    Capitalize-FirstLetter -word "hello"
    Returns "Hello"
#>
function Capitalize-FirstLetter {
    param (
        [string]$word
    )

    if ([string]::IsNullOrEmpty($word)) {
        return $word
    }

    return $word.Substring(0,1).ToUpper() + $word.Substring(1)
}
