#! /usr/bin/env bash

defaultConfig="$(dirname "${BASH_SOURCE[0]}")/../../config/default"
if [ -f "${defaultConfig}" ]; then
	. "${defaultConfig}"
fi

REGISTRY="${REGISTRY:-localhost:5000}"
export REGISTRY WAVELET_TAG

set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

WAVELET_TAG="${WAVELET_TAG:-latest}"

sed '
	s|${REGISTRY}|'"${REGISTRY}"'|g
	s|${WAVELET_TAG}|'"${WAVELET_TAG}"'|g
' Dockerfile | docker build -f - -t "${REGISTRY}/wavelet-stack-node:${WAVELET_TAG}" .
docker push "${REGISTRY}/wavelet-stack-node:${WAVELET_TAG}"
