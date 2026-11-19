#!/usr/bin/env bash
set -euo pipefail

IMAGE="ghcr.io/${GITHUB_REPOSITORY,,}"
VERSION_IMAGE="${IMAGE}:${GITHUB_REF_NAME}"
SHA_IMAGE="${IMAGE}:sha-${GITHUB_SHA:0:12}"

docker tag "${CANDIDATE_IMAGE:?CANDIDATE_IMAGE is required}" "$VERSION_IMAGE"
docker tag "$CANDIDATE_IMAGE" "$SHA_IMAGE"
docker push "$SHA_IMAGE"
docker push "$VERSION_IMAGE" | tee docker-push.log

DIGEST="$(sed -n \
  's/.*digest: \(sha256:[0-9a-f]\{64\}\).*/\1/p' \
  docker-push.log | tail -n 1)"
if [[ -z "$DIGEST" ]]; then
  echo 'Registry did not return a manifest digest.' >&2
  exit 1
fi

echo "PUBLISHED_IMAGE=${IMAGE}@${DIGEST}" >> "$GITHUB_ENV"
echo "Published ${IMAGE}@${DIGEST}"
