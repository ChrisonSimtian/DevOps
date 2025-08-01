# Powershell

This is a collection of useful powershell guides

## Tipps and Tricks

In order to enforce UTF-8 with BOM add this snippet to your ```.gitattributes```

```conf
    *.ps1 text working-tree-encoding=UTF-8
```

Or run this script to convert locally:

```shell
    Get-Content .\script.ps1 | Set-Content -Encoding UTF8 -Path .\script-fixed.ps1
```

This little snippet lets you define requirements that automatically get imported:

```shell
    #Requires -Modules GetInfo
```

## Authoring your own Modules

A Powershell Module is basically the same as writing your own C# library and allows you to collect reusable scripts in a modular collection.

## Hosting your Powershell

Spin up a Nuget Server, give it an API Key and then run the following command:

```shell
    Import-Module PowerShellGet

    $apiKey = 41b9062f-f2d9-4292-a1d2-57262cea872e
    $uri = 'http://localhost:5000'
    $repo = @{
        Name = 'MyRepository'
        SourceLocation = $uri
        PublishLocation = $uri
        InstallationPolicy = 'Trusted'
    }
    Register-PSRepository @repo
```

In order to publish packages, run the following code:

```shell
    Publish-Module -Name MyModule -Repository MyRepository -NuGetApiKey $apiKey
```

## Links

- [Authoring Modules](https://powershellexplained.com/2017-05-27-Powershell-module-building-basics/?utm_source=blog&utm_medium=blog&utm_content=psrepository)
- [Powershell Repository Guide](https://powershellexplained.com/2017-05-30-Powershell-your-first-PSScript-repository/?utm_source=blog&utm_medium=blog&utm_content=nuget)
- [Nuget Server as Powershell Repository](https://powershellexplained.com/2018-03-03-Powershell-Using-a-NuGet-server-for-a-PSRepository/)
