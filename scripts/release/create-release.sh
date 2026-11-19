#!/usr/bin/env bash
set -euo pipefail

if gh release view "$GITHUB_REF_NAME" >/dev/null 2>&1; then
  echo 'GitHub Release already exists; refusing to overwrite.' >&2
  exit 1
fi

printf 'Verified container image:\n\n`%s`\n\n' \
  "$PUBLISHED_IMAGE" > release-notes.md
printf 'Commit: `%s`\n' "$GITHUB_SHA" >> release-notes.md

gh release create "$GITHUB_REF_NAME" \
  --verify-tag \
  --title "$GITHUB_REF_NAME" \
  --notes-file release-notes.md
