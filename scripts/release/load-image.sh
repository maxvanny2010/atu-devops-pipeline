#!/usr/bin/env bash
set -euo pipefail

: "${CANDIDATE_IMAGE:?CANDIDATE_IMAGE is required}"
: "${GITHUB_SHA:?GITHUB_SHA is required}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"
: "${GITHUB_SERVER_URL:?GITHUB_SERVER_URL is required}"

sha256sum --check release-image.sha256
gzip -dc release-image.tar.gz | docker load

actual_id="$(docker image inspect --format '{{.Id}}' "$CANDIDATE_IMAGE")"
expected_id="$(< release-image-id.txt)"
[[ "$actual_id" == "$expected_id" ]] || {
  echo 'Docker image ID mismatch.' >&2
  exit 1
}

revision="$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.revision"}}' "$CANDIDATE_IMAGE")"
source="$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.source"}}' "$CANDIDATE_IMAGE")"
[[ "$revision" == "$GITHUB_SHA" ]] || {
  echo 'Image revision label does not match GITHUB_SHA.' >&2
  exit 1
}
[[ "$source" == "${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}" ]] || {
  echo 'Image source label does not match this repository.' >&2
  exit 1
}
