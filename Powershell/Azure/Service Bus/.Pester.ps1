# Invoke-Pester -Path .\Tests

Invoke-Pester -Script @{
    Path = '.\Tests'
    Output = 'Detailed'
}