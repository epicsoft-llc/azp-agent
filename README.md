# Azure Pipelines agent

This Docker image is managed and kept up to date by [epicsoft LLC](https://epicsoft.one).

Self-hosted agents for [Azure Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker) in a
container, built after Microsoft's instructions: the container registers itself in your agent pool, runs jobs and
removes itself again when it stops. The image brings the Azure CLI, git, jq and curl; the agent itself is downloaded at
start in the version your Azure DevOps organization hands out. On Ubuntu 26.04 or Alpine, for `linux/amd64` and
`linux/arm64`, with versioned releases you can pin.

* Base images: https://hub.docker.com/_/ubuntu (`ubuntu:26.04`) and https://hub.docker.com/_/python (`python:3.14-alpine`), platforms `linux/amd64` and `linux/arm64`
* Instructions this image follows: https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker
* Dockerfiles: https://gitlab.com/epicsoft-networks/azp-agent/-/blob/main/Dockerfile.ubuntu26.04 and https://gitlab.com/epicsoft-networks/azp-agent/-/blob/main/Dockerfile.alpine
* Repository: https://gitlab.com/epicsoft-networks/azp-agent, mirrored to [GitHub](https://github.com/epicsoft-llc/azp-agent) — issues are welcome on both; code changes only as merge requests on GitLab, the mirror overwrites anything pushed to GitHub
* Container registry: https://gitlab.com/epicsoft-networks/azp-agent/container_registry
* Docker Hub: https://hub.docker.com/r/epicsoft/azp-agent
* Changelog: https://gitlab.com/epicsoft-networks/azp-agent/-/blob/main/CHANGELOG.md
* License: MIT

## Versions

Released through a git tag `X.Y.Z`. A release is built once and never changed afterwards, so a pipeline that pins it
runs on the same Azure CLI and the same system packages every time. The changelog names what each release contains.

| Tag | Content |
|---|---|
| `1.0.0`, `1.0.0-ubuntu26.04` | exactly this build on Ubuntu 26.04 - **pin this in pipelines you want to reproduce** |
| `1.0.0-alpine` | exactly this build on Alpine |
| `1.0`, `1`, `1.0-ubuntu26.04`, `1-ubuntu26.04` | newest release of that line on Ubuntu 26.04 |
| `1.0-alpine`, `1-alpine` | newest release of that line on Alpine |
| `latest`, `ubuntu26.04`, `ubuntu-latest` | the `main` branch on Ubuntu 26.04, rebuilt weekly, also moved by every release |
| `alpine`, `alpine-latest` | the `main` branch on Alpine, rebuilt weekly, also moved by every release |

No longer built: `ubuntu22.04` and `ubuntu22.04-latest` stay on Docker Hub as they were on 2026-10-14.

A pinned image does not pin the agent: it is downloaded when the container starts, in the version your organization
offers. Its version is in the job log of every run.

## Quick start

Create a personal access token with the scope *Agent Pools (read, manage)*, then:

```bash
docker run -d --name azp-agent \
  -e AZP_URL="https://dev.azure.com/<organization>" \
  -e AZP_TOKEN="<personal access token>" \
  -e AZP_POOL="<agent pool>" \
  -e AZP_AGENT_NAME="docker-agent-1" \
  epicsoft/azp-agent:1.0.0
```

The token can come from a file instead, which keeps it out of `docker inspect`:

```bash
docker run -d --name azp-agent \
  -e AZP_URL="https://dev.azure.com/<organization>" \
  -e AZP_TOKEN_FILE=/run/secrets/azp_token \
  -v /srv/azp/token:/run/secrets/azp_token:ro \
  -e AZP_POOL="<agent pool>" \
  epicsoft/azp-agent:1.0.0
```

**One job per container:** arguments after the image name go to the agent's `run.sh`. With `--once` the agent takes a
single job and exits - together with `--rm` and a restart policy of the orchestrator, every job gets a fresh container.

```bash
docker run --rm -e AZP_URL=... -e AZP_TOKEN_FILE=... epicsoft/azp-agent:1.0.0 --once
```

## Environment variables

| Variable | Default | Meaning |
|---|---|---|
| `AZP_URL` | - | URL of the Azure DevOps organization or server, required |
| `AZP_TOKEN` | - | personal access token |
| `AZP_TOKEN_FILE` | - | file with the token, instead of `AZP_TOKEN` |
| `AZP_CLIENTID`, `AZP_CLIENTSECRET`, `AZP_TENANTID` | - | service principal; the token is fetched with `az login` instead |
| `AZP_POOL` | `Default` | agent pool |
| `AZP_AGENT_NAME` | host name of the container | name of the agent in the pool |
| `AZP_WORK` | `_work` | working directory for the jobs |
| `TARGETARCH` | detected | agent package platform (`linux-x64`, `linux-arm64`, `linux-musl-x64`, `linux-musl-arm64`) |

The agent runs as user `agent` (uid `1000`) in `/azp`. Microsoft describes the variables in its
[instructions](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker#environment-variables).

## Ubuntu or Alpine

| | Ubuntu 26.04 | Alpine |
|---|---|---|
| Size | about 1.2 GB | about 1 GB |
| C library | glibc - tools and binaries built for common Linux run as they are | musl - some prebuilt binaries do not run |
| Azure CLI | Microsoft's apt package | from PyPI, on Python 3.14 |

When in doubt, take Ubuntu: pipeline tasks often download tools built for glibc.

## Installed packages

Both images: `ca-certificates`, `curl`, `git`, `jq` and ICU for the agent, plus the Azure CLI. Packages are upgraded
at every build, so the image does not wait for the next base image to get their security fixes.

## Reporting problems

Issues are welcome on [GitLab](https://gitlab.com/epicsoft-networks/azp-agent/-/issues) and
[GitHub](https://github.com/epicsoft-llc/azp-agent/issues). Please report a security problem as a
**confidential issue** on GitLab instead of a public one. Problems of the agent itself belong to
[Microsoft](https://github.com/microsoft/azure-pipelines-agent/issues).

## License

[MIT](https://gitlab.com/epicsoft-networks/azp-agent/-/blob/main/LICENSE) — Copyright (c) 2025-2026 epicsoft LLC / Alexander Schwarz

The MIT license applies only to files created by epicsoft LLC. Third-party software in the image — the Azure Pipelines
agent, the Azure CLI, the Ubuntu, Alpine and Python packages and the official base images — remains under its own
licenses. `start.sh` follows the script in Microsoft's instructions.
