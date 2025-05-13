# Azure DevOps Backup

This Docker image is managed and kept up to date by [epicsoft LLC](https://epicsoft.one).

Docker images for Microsoft Azure-DevOps Self-Hosting Agents.

* Base images: 
  - https://hub.docker.com/_/python (python:3-alpine)
  - https://hub.docker.com/_/ubuntu (ubuntu:22.04 and ubuntu:24.04)
* Dockerfiles: 
  - https://gitlab.com/epicsoft-networks/azp-agent/blob/main/Dockerfile.apline
  - https://gitlab.com/epicsoft-networks/azp-agent/blob/main/Dockerfile.ubuntu22
  - https://gitlab.com/epicsoft-networks/azp-agent/blob/main/Dockerfile.ubuntu24
* Repository: https://gitlab.com/epicsoft-networks/azp-agent/tree/main
* Container-Registry: https://gitlab.com/epicsoft-networks/azp-agent/container_registry
* Docker Hub: https://hub.docker.com/r/epicsoft/azp-agent

## Description

Docker images for Microsoft Azure-DevOps-Pipelines Self-Hosting Agents.  
Created according to Microsoft's instructions with minor adjustments.  
https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops

## Versions

`alpine` based on `python:3-alpine` - build `weekly`
`ubuntu22.04` based on `ubuntu:22.04` - build `weekly`
`ubuntu24.04` based on `ubuntu:24.04` - build `weekly`

## Environment variables

https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops#environment-variables

## Installed addition packages

Packages installed in addition to the instructions:

- ca-certificates

## Examples


## License

MIT License see [LICENSE](https://gitlab.com/epicsoft-networks/azp-agent/blob/main/LICENSE)

Please note that the MIT license only applies to the files created by epicsoft LLC. Other software may be licensed under other licenses.
