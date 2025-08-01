# Bagetter

[Bagetter](https://www.bagetter.com/) is a Nuget Server, selfhosted in Docker

## Quick Start

Publish a Package:

```bash
dotnet nuget push -s http://localhost:5000/v3/index.json -k NUGET-SERVER-API-KEY package.1.0.0.nupkg
```

Publish a Symbol Package:

```bash
dotnet nuget push -s http://localhost:5000/v3/index.json -k NUGET-SERVER-API-KEY symbol.package.1.0.0.snupkg
```
