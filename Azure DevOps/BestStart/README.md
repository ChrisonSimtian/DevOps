# Introduction 
Repository to host files and documentation around DevOps at BestStart.

# Build Pipelines
Put this into your build.yml to reference a predefined yml template and use the defined job steps.
```
variables:
  solution: '**/*.sln'
  buildPlatform: 'Any CPU'
  buildConfiguration: 'UAT'
  project: 'BestStart.Websites.Chris21Api'

resources: 
  repositories: 
  - repository: DevOps 
    name: DevOps/DevOps 
    type: git 
    ref: main #branch name

jobs:
- job: Build
  displayName: 'Build Project'
  steps:
  - template: build-web-app.yml@DevOps
    parameters:
      buildConfiguration: $(buildConfiguration)
      project: $(project)
```

## Defined templates
### Web App
The ```build-web-app.yml``` template helps you with building DotNet Core WebApps.

# Literature
- [Share YAML files across repositories](https://elanderson.net/2020/04/azure-devops-pipelines-use-yaml-across-repos/)
- [YAML template](https://elanderson.net/2020/03/azure-devops-pipelines-reuseable-yaml/)
- [Build via scheduled Triggers](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/scheduled-triggers?tabs=yaml&view=azure-devops#branch-considerations-for-scheduled-triggers)
- [CronTab Builder](https://crontab.guru/)