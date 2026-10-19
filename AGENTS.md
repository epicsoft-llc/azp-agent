# AGENTS.md

Guidance for AI coding agents and contributors working in this repository.

## What this repository is

Docker images for self-hosted Azure Pipelines agents, built after
[Microsoft's instructions](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker). The Dockerfiles,
`start.sh` (Microsoft's script with small changes) and `platform.sh` are the product; `test/smoke.sh` checks it, and
`README.md` is the published Docker Hub description, uploaded by the pipeline - part of the release artifact.

| | |
|---|---|
| **Repository** | developed on `gitlab.com/epicsoft-networks/azp-agent` (branch `main`), mirrored to `github.com/epicsoft-llc/azp-agent` |
| **Registries** | `registry.gitlab.com/epicsoft-networks/azp-agent` and Docker Hub `epicsoft/azp-agent` |
| **Variants** | `Dockerfile.ubuntu26.04` (default, `latest`) and `Dockerfile.alpine` |
| **Platforms** | `linux/amd64` and `linux/arm64` |

## Image design

- **The agent is not in the image.** `start.sh` asks the organization for the newest agent package of its platform,
  downloads it, configures it with `config.sh`, runs `run.sh` with the container's arguments and removes the agent from
  the pool on exit. A release therefore pins the Azure CLI and the system packages, not the agent.
- **`platform.sh`** prints the agent package platform (`linux-x64`, `linux-arm64`, `linux-musl-x64`,
  `linux-musl-arm64`) from `uname -m` and the C library; `TARGETARCH` in the environment overrides it, as in
  Microsoft's script.
- **Ubuntu:** the Azure CLI comes from Microsoft's apt repository, set up as `https://aka.ms/InstallAzureCLIDeb` does it,
  but without piping a script into a shell. `libicu<N>` is versioned per Ubuntu release - a new Ubuntu line needs the
  new package name. The base image's user `ubuntu` is removed so that `agent` gets uid 1000, as on Alpine.
- **Alpine:** Alpine does not package the Azure CLI, so it is installed from PyPI into a venv in a builder stage; only
  the venv and the runtime libraries reach the image. The Python line is the newest one the Azure CLI supports - check
  the classifiers of `azure-cli` on PyPI before raising it.
- **`apk --no-cache upgrade` / `apt-get upgrade`** run at every build: the base images lag behind their repositories.
- The agent runs as `agent` (uid 1000) in `/azp`, which it owns; the scripts are copied with `COPY --chmod=755`.
- Both label blocks, `org.label-schema.*` and `image.*`/`maintainer.*`, are maintained together.

## Tests

```bash
docker build -t azp-agent:test --pull --no-cache -f Dockerfile.ubuntu26.04 .
sh test/smoke.sh azp-agent:test                    # optionally a platform as second argument
```

`test/smoke.sh` checks uid and working directory, `az version`, that `start.sh` refuses to start without `AZP_URL`,
and that the newest agent release for the platform `platform.sh` reports runs (`Agent.Listener --version`). It needs
internet access (GitHub API and `download.agent.dev.azure.com`). The pipeline runs it for every variant and platform
before the push.

## Releases, tags and pipeline (`.gitlab-ci.yml`)

Semantic versioning, see `CHANGELOG.md`. **A release is a git tag `X.Y.Z`** (protected tags `*.*.*`) with a changelog
entry `## [X.Y.Z] - <date>`; the build fails without it.

| Pipeline | Tags |
|---|---|
| default branch, weekly schedule | `ubuntu26.04`, `ubuntu-latest`, `latest` - `alpine`, `alpine-latest` |
| tag `X.Y.Z` | the above, plus `X.Y.Z-<variant>`, `X.Y-<variant>`, `X-<variant>`, and `X.Y.Z`, `X.Y`, `X` for the default variant |

One job per variant extends `.build` and sets `VARIANT` (the Dockerfile suffix and the line tag), `EXTRA_TAGS` and, for
Ubuntu, `DEFAULT_VARIANT`. Each platform is built, loaded and smoke-tested before the multi-platform push, which reuses
those layers from the builder cache. The `docker:dind` service runs with TLS, which buildx only takes from a Docker
context - hence `docker context create dind`. `linux/arm64` needs QEMU (`binfmt_misc`) on the runner host, which is
why the jobs carry the runner tag `imagex`. `github-release` waits for the tag on GitHub and creates the release from
the changelog entry.

CI variables: `DOCKER_HUB_USER`, `DOCKER_HUB_TOKEN`, `GITHUB_TOKEN` (masked, protected). The tokens go in over stdin
and through the environment, never onto a command line.

**GitHub mirror:** a push mirror in the GitLab project settings with its own token - not part of the pipeline. Changes
are never pushed to GitHub directly; the mirror would overwrite them.

### Release checklist

1. `CHANGELOG.md`: `## [X.Y.Z] - <date>` with `### Contents` - Azure CLI, Ubuntu, Alpine and Python versions, read
   from a fresh build
2. `README.md`: the version in the `## Versions` table and in the examples
3. Tag `X.Y.Z` without `v` on the green commit of `main`

### Adding or retiring an Ubuntu line

A `Dockerfile.ubuntu<version>` with the matching `libicu<N>`, a job in `.gitlab-ci.yml`, the tables in `README.md`
(a retired line goes under "No longer built") and this file. Moving `latest` to another line is a major release.

## Conventions

- `.editorconfig`: 2-space indent, LF, UTF-8, final newline, trailing whitespace trimmed (except Markdown), 120 columns
  (180 for YAML, off for Markdown); `.gitattributes` keeps LF in the repository.
- `platform.sh` and `test/smoke.sh` are POSIX `sh`; `start.sh` stays `bash`, as in Microsoft's script.
- Commit messages follow Conventional Commits (`feat:`, `fix:`, `ci:`, `chore:`).
