#!/bin/sh
#### sh test/smoke.sh <image> [platform]

set -e

export MSYS_NO_PATHCONV=1

readonly IMAGE="$1"
readonly PLATFORM="${2:-}"

PLATFORM_ARG=""
if [ -n "${PLATFORM}" ]; then
  PLATFORM_ARG="--platform=${PLATFORM}"
fi

run() {
  docker run --rm ${PLATFORM_ARG} --entrypoint bash "${IMAGE}" -c "$1" # ok: optional
}

fail() {
  echo "FAIL: $1"
  exit 1
}

[ "$(run "id -u"):$(run "pwd")" = "1000:/azp" ] || fail "the agent does not run as uid 1000 in /azp"
echo "ok: uid 1000 in /azp"

run "az version --output tsv --query '\"azure-cli\"'" || fail "az version"
echo "ok: Azure CLI"

OUTPUT=$(docker run --rm ${PLATFORM_ARG} "${IMAGE}" 2>&1 || true) # ok: optional
case "${OUTPUT}" in
  *"missing AZP_URL"*) echo "ok: start.sh refuses to start without AZP_URL" ;;
  *) fail "start.sh without AZP_URL: ${OUTPUT}" ;;
esac

run "set -e
  platform=\$(./platform.sh)
  version=\$(curl -fsSL https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest | jq -r .tag_name)
  version=\${version#v}
  echo \"agent \${version} for \${platform}\"
  mkdir /tmp/agent && cd /tmp/agent
  curl -fsSL --retry 3 --retry-all-errors -o agent.tar.gz https://download.agent.dev.azure.com/agent/\${version}/vsts-agent-\${platform}-\${version}.tar.gz
  tar -xzf agent.tar.gz
  ./bin/Agent.Listener --version" || fail "the Azure Pipelines agent does not run"
echo "ok: the Azure Pipelines agent runs"

echo "smoke test passed${PLATFORM:+ on ${PLATFORM}}"
