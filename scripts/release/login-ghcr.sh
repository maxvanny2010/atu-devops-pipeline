#!/usr/bin/env bash
set -euo pipefail

echo "$GH_TOKEN" | docker login ghcr.io \
  --username "$GITHUB_ACTOR" --password-stdin
