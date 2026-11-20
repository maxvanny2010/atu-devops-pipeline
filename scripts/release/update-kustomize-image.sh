#!/usr/bin/env bash
set -euo pipefail

image="${1:?Usage: update-kustomize-image.sh IMAGE@sha256:DIGEST [FILE]}"
file="${2:-k8s/overlays/release/kustomization.yaml}"

if [[ ! "$image" =~ ^ghcr\.io/maxvanny2010/atu-devops-pipeline@sha256:[0-9a-f]{64}$ ]]; then
  echo 'ERROR: Expected the full GHCR image with a SHA256 digest' >&2
  exit 1
fi

if [[ ! -f "$file" ]]; then
  echo "ERROR: Missing Kustomize file: $file" >&2
  exit 1
fi

if [[ ! -w "$file" ]]; then
  echo "ERROR: Kustomize file is not writable: $file" >&2
  exit 1
fi

name_count="$(grep -Ec '^[[:space:]]*newName:' "$file" || true)"
version_count="$(grep -Ec '^[[:space:]]*(digest|newTag):' "$file" || true)"

if [[ "$name_count" != 1 || "$version_count" != 1 ]]; then
  echo 'ERROR: Expected one newName and one digest or newTag entry' >&2
  exit 1
fi

if ! grep -Eq \
  '^[[:space:]]*newName:[[:space:]]*ghcr\.io/maxvanny2010/atu-devops-pipeline[[:space:]]*$' \
  "$file"; then
  echo 'ERROR: Unexpected image repository in Kustomize file' >&2
  exit 1
fi

if ! grep -Eq \
  '^[[:space:]]*(digest:[[:space:]]*sha256:[0-9a-f]{64}|newTag:[[:space:]]*v[0-9]+\.[0-9]+\.[0-9]+)[[:space:]]*$' \
  "$file"; then
  echo 'ERROR: Existing image version is invalid' >&2
  exit 1
fi

digest="${image##*@}"

if grep -Eq \
  "^[[:space:]]*digest:[[:space:]]*${digest}[[:space:]]*$" "$file"; then
  echo 'PASS: Kustomize already references the requested digest'
  exit 0
fi

sed -i -E \
  "s/^([[:space:]]*)(digest|newTag):[[:space:]]*(sha256:[0-9a-f]{64}|v[0-9]+\.[0-9]+\.[0-9]+)[[:space:]]*$/\1digest: ${digest}/" \
  "$file"

if ! grep -Eq \
  "^[[:space:]]*digest:[[:space:]]*${digest}$" "$file"; then
  echo 'ERROR: Could not verify the updated digest' >&2
  exit 1
fi

echo "PASS: Kustomize now references ${image}"
