#!/usr/bin/env bash
set -euo pipefail

: "${GH_TOKEN:?GH_TOKEN is required}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"
: "${GITHUB_REF_NAME:?GITHUB_REF_NAME is required}"
: "${GITHUB_SHA:?GITHUB_SHA is required}"

status="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}'   --header "Authorization: Bearer ${GH_TOKEN}"   --header 'Accept: application/vnd.github+json'   "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/tags/${GITHUB_REF_NAME}")"
case "$status" in
  404) ;;
  200) echo 'GitHub Release already exists; refusing to overwrite.' >&2; exit 1 ;;
  *) echo "Cannot verify GitHub Release availability (HTTP ${status})." >&2; exit 1 ;;
esac

base="ghcr.io/${GITHUB_REPOSITORY,,}"
for ref in "${base}:${GITHUB_REF_NAME}" "${base}:sha-${GITHUB_SHA:0:12}"; do
  if output="$(docker buildx imagetools inspect "$ref" 2>&1)"; then
    echo "Container tag already exists: $ref" >&2
    exit 1
  fi
  if [[ ! "$output" =~ [Nn]ot[[:space:]]found|[Mm]anifest[[:space:]]unknown|[Nn]ame[[:space:]]unknown|404 ]]; then
    echo "Cannot establish whether GHCR tag exists: $ref" >&2
    echo "$output" >&2
    exit 1
  fi
done
