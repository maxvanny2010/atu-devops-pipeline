#!/usr/bin/env bash
set -euo pipefail

docker build \
  --label "org.opencontainers.image.source=${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}" \
  --label "org.opencontainers.image.revision=${GITHUB_SHA}" \
  --tag "${CANDIDATE_IMAGE:?CANDIDATE_IMAGE is required}" .
