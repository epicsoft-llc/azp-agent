#!/bin/sh
#### prints the Azure Pipelines agent package platform of this container, e.g. linux-musl-x64

case "$(uname -m)" in
  x86_64) arch="x64" ;;
  aarch64) arch="arm64" ;;
  *)
    echo "unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

if [ -f /etc/alpine-release ]; then
  echo "linux-musl-${arch}"
else
  echo "linux-${arch}"
fi
