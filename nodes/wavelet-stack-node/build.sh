#! /usr/bin/env bash

REGISTRY="${REGISTRY:-localhost:5000}"
export REGISTRY

defaultConfig="$(dirname "${BASH_SOURCE[0]}")/../../config/default"
if [ -f "${defaultConfig}" ]; then
	. "${defaultConfig}"
fi

set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

sed 's|${REGISTRY}|'"${REGISTRY}"'|g' Dockerfile | docker build -f - -t "${REGISTRY}/wavelet-stack-node:latest" .
docker push "${REGISTRY}/wavelet-stack-node:latest"
