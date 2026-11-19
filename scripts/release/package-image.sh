#!/usr/bin/env bash
set -euo pipefail

: "${CANDIDATE_IMAGE:?CANDIDATE_IMAGE is required}"
docker image inspect --format '{{.Id}}' "$CANDIDATE_IMAGE" > release-image-id.txt
docker save "$CANDIDATE_IMAGE" | gzip -1 > release-image.tar.gz
sha256sum release-image.tar.gz release-image-id.txt > release-image.sha256
