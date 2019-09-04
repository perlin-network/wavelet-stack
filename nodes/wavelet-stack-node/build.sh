#! /usr/bin/env bash

defaultConfig="$(dirname "${BASH_SOURCE[0]}")/../../config/default"
if [ -f "${defaultConfig}" ]; then
	. "${defaultConfig}"
fi

REGISTRY="${REGISTRY:-localhost:5000}"
export REGISTRY

set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

sed 's|${REGISTRY}|'"${REGISTRY}"'|g' Dockerfile | docker build -f - -t "${REGISTRY}/wavelet-stack-node:latest" .
docker push "${REGISTRY}/wavelet-stack-node:latest"
