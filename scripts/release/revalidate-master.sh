#!/usr/bin/env bash
set -euo pipefail

MASTER_SHA="$(gh api "repos/${GITHUB_REPOSITORY}/branches/master" --jq '.commit.sha')"
if [[ "$GITHUB_SHA" != "$MASTER_SHA" ]]; then
  echo 'Master moved while release was verified; aborting.' >&2
  exit 1
fi
