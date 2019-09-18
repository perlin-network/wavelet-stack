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

if [ -n "${WAVELET_BUILD_DIR}" ]; then
	"${MAKE:-make}" -C "${WAVELET_BUILD_DIR}" docker R="${REGISTRY}" T="${WAVELET_TAG}"
fi

sed '
	s|${REGISTRY}|'"${REGISTRY}"'|g
	s|${WAVELET_TAG}|'"${WAVELET_TAG}"'|g
' Dockerfile | docker build -f - -t "${REGISTRY}/wavelet-stack-node:${WAVELET_TAG}" .
docker push "${REGISTRY}/wavelet-stack-node:${WAVELET_TAG}"
