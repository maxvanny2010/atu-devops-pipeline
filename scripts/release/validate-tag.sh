#!/usr/bin/env bash
set -euo pipefail

if [[ ! "$GITHUB_REF_NAME" =~ ^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]; then
  echo 'Expected a stable SemVer tag such as v0.1.0.' >&2
  exit 1
fi

MASTER_SHA="$(gh api "repos/${GITHUB_REPOSITORY}/branches/master" --jq '.commit.sha')"
if [[ "$GITHUB_SHA" != "$MASTER_SHA" ]]; then
  echo 'Tag must point to the current master commit.' >&2
  exit 1
fi
