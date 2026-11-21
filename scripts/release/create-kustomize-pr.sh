#!/usr/bin/env bash
set -Eeuo pipefail

image="${PUBLISHED_IMAGE:?PUBLISHED_IMAGE is required}"
version="${GITHUB_REF_NAME:?GITHUB_REF_NAME is required}"
repo="${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"

if [[ ! "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: Invalid release version: $version" >&2
  exit 1
fi

expected="ghcr.io/${repo,,}@sha256:"
if [[ "$image" != "$expected"* || ! "$image" =~ @sha256:[0-9a-f]{64}$ ]]; then
  echo 'ERROR: Invalid published image or repository' >&2
  exit 1
fi

if [[ "$repo" != 'maxvanny2010/atu-devops-pipeline' ]]; then
  echo 'ERROR: Unexpected GitHub repository' >&2
  exit 1
fi

branch="automation/kustomize-${version}"

# A GitHub Release must exist before the manifest update is proposed.
gh release view "$version" --repo "$repo" >/dev/null

# Only the temporary GitHub Actions runner is configured for Git auth.
gh auth setup-git

git fetch origin master

if git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
  echo "ERROR: Remote branch already exists: $branch" >&2
  exit 1
fi

tmp="$(mktemp -d)"
worktree="$tmp/worktree"
cleanup() {
  git worktree remove --force "$worktree" >/dev/null 2>&1 || true
  rm -rf "$tmp"
}
trap cleanup EXIT

git worktree add --detach "$worktree" origin/master
git -C "$worktree" switch -c "$branch"

(
  cd "$worktree"
  bash scripts/release/test-kustomize-image.sh
  bash scripts/release/update-kustomize-image.sh "$image"
  git add -- k8s/overlays/release/kustomization.yaml
  git diff --cached --check
  if git diff --cached --quiet; then
    echo "PASS: master already references $image; no PR required"
    exit 10
  fi
  git -c user.name='github-actions[bot]' \
      -c user.email='41898282+github-actions[bot]@users.noreply.github.com' \
      commit -m "chore(k8s): update release image for $version"
 ) || result=$?
result="${result:-0}"
if [[ "$result" == 10 ]]; then
  exit 0
fi
if [[ "$result" != 0 ]]; then
  exit "$result"
fi

git -C "$worktree" push origin "HEAD:refs/heads/$branch"

cat > "$tmp/pr-body.md" <<BODY
## Summary

Update the Kubernetes release image to the verified $version digest.

## Changes

- Update Kustomize to $image.

## Testing and Validation

- [x] Offline updater tests passed.
- [x] Staged whitespace checks passed.
- [ ] Kubernetes manifest workflow (dispatched separately).

## Conclusion

The immutable image reference is ready for review. Merge remains manual.
BODY

gh pr create --repo "$repo" --base master --head "$branch" \
  --title "chore(k8s): update release image for $version" \
  --body-file "$tmp/pr-body.md"

# Bot-created PRs do not trigger ordinary pull_request workflows.
# workflow_dispatch is explicitly exempt from that restriction.
gh workflow run kubernetes-validation.yml --repo "$repo" --ref "$branch"

echo "PASS: Digest update PR created and Kubernetes validation dispatched: $branch"
