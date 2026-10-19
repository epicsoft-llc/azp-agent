# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
the versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

| Part | Raised when |
|---|---|
| **MAJOR** | an existing setup stops working - a removed variable, `latest` on another Ubuntu line, a changed user |
| **MINOR** | a variant, a variable or a feature is added without changing existing setups |
| **PATCH** | a rebuild with updated packages or Azure CLI, or a fix |

**A release is a git tag `X.Y.Z`.** CI builds `X.Y.Z-<variant>`, `X.Y-<variant>` and `X-<variant>` from it for every
variant - and `X.Y.Z`, `X.Y`, `X` for Ubuntu, the default - for `linux/amd64` and `linux/arm64`, moves the line tags
and creates the GitHub release from the entry below. Each entry names the contained versions. The weekly builds of the
line tags are not listed here. The Azure Pipelines agent is not part of the image; it is downloaded when the container
starts.

## [1.0.0] - 2026-10-19

### Contents

- Ubuntu variant: Ubuntu `26.04.1`, Azure CLI `2.91.0` (Microsoft's apt package, with its own Python `3.14.7`)
- Alpine variant: Alpine `3.24.2`, Python `3.14.8`, Azure CLI `2.91.0`
- Tested with the Azure Pipelines agent `5.280.0`

### Added

- **Releases** from git tags `X.Y.Z`: image tags that are built once and never change, so a pipeline can pin the
  exact image it ran on, and a GitHub release from this changelog
- **Ubuntu 26.04** as `ubuntu26.04`
- **`linux/arm64`** for both variants, next to `linux/amd64`. `platform.sh` picks the matching agent package
  (`linux-x64`, `linux-arm64`, `linux-musl-x64`, `linux-musl-arm64`); `TARGETARCH` still overrides it
- Every image goes through `test/smoke.sh` before it is pushed, on every platform: user and working directory,
  `az version`, the refusal without `AZP_URL`, and the newest agent release starting on that platform
- A mirror on GitHub: `github.com/epicsoft-llc/azp-agent`

### Changed

- `latest` and `ubuntu-latest` are Ubuntu 26.04 now
- The Alpine image is about 1 GB instead of 2.2 GB: the Azure CLI is built in a separate stage, and the compilers no
  longer reach the image. It runs on `python:3.14-alpine` - `python:3-alpine` moved to Python 3.15, which the Azure
  CLI does not support yet
- The Ubuntu image takes the Azure CLI straight from Microsoft's apt repository instead of piping
  `https://aka.ms/InstallAzureCLIDeb` into a shell
- The weekly build runs on Sundays, and the pipeline takes its tokens over stdin and through the environment instead of
  the command line
- The labels point to this repository and carry copyright and license

### Removed

- Ubuntu 22.04: `ubuntu22.04` and `ubuntu22.04-latest` are no longer built and stay as they were on 2026-10-14

### Breaking

| | Now | Was |
|---|---|---|
| `latest`, `ubuntu-latest` | Ubuntu 26.04 | Ubuntu 22.04 |
| Alpine base | `python:3.14-alpine` | `python:3-alpine` |

The agent keeps running as user `agent` with uid `1000` in `/azp`.
