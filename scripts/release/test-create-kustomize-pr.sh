#!/usr/bin/env bash
set -Eeuo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/source/scripts/release" "$tmp/source/k8s/overlays/release" "$tmp/bin"
cp "$root/scripts/release/create-kustomize-pr.sh" "$tmp/source/scripts/release/"
cp "$root/scripts/release/update-kustomize-image.sh" "$tmp/source/scripts/release/" 2>/dev/null || true
cp "$root/scripts/release/test-kustomize-image.sh" "$tmp/source/scripts/release/" 2>/dev/null || true
# The existing updater and tests must be present in the real project; fixture stubs
# exercise only orchestration, not their separate unit-tested behaviour.
cat > "$tmp/source/scripts/release/test-kustomize-image.sh" <<'TEST'
#!/usr/bin/env bash
set -euo pipefail
exit 0
TEST
cat > "$tmp/source/scripts/release/update-kustomize-image.sh" <<'UPDATE'
#!/usr/bin/env bash
set -euo pipefail
[[ "$1" =~ @sha256:[0-9a-f]{64}$ ]]
sed -i -E 's/newTag: v[0-9.]+/digest: '"${1##*@}"'/' k8s/overlays/release/kustomization.yaml
UPDATE
cat > "$tmp/source/k8s/overlays/release/kustomization.yaml" <<'YAML'
images:
  - name: task-manager
    newName: ghcr.io/maxvanny2010/atu-devops-pipeline
    newTag: v0.1.2
YAML

git init -q --initial-branch=master "$tmp/source"
git -C "$tmp/source" add .
git -C "$tmp/source" -c user.name=test -c user.email=test@example.com commit -qm initial
git clone -q --bare "$tmp/source" "$tmp/remote.git"
git -C "$tmp/source" remote add origin "$tmp/remote.git"
cat > "$tmp/bin/gh" <<'GH'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$GH_MOCK_LOG"
case "$1 $2" in
  'auth setup-git') exit 0 ;;
  'release view') exit 0 ;;
  'pr create') echo 'https://example.invalid/pr/1'; exit 0 ;;
  'workflow run') exit 0 ;;
  *) echo 'unexpected gh call' >&2; exit 1 ;;
esac
GH
chmod +x "$tmp/bin/gh"
export GH_MOCK_LOG="$tmp/gh-commands.log"
export PATH="$tmp/bin:$PATH"
export GH_TOKEN='offline-fixture-only'
export GITHUB_REPOSITORY='maxvanny2010/atu-devops-pipeline'
export GITHUB_REF_NAME='v0.1.3'
export PUBLISHED_IMAGE="ghcr.io/maxvanny2010/atu-devops-pipeline@sha256:$(printf 'b%.0s' {1..64})"
(
  cd "$tmp/source"
  bash scripts/release/create-kustomize-pr.sh
)
git --git-dir="$tmp/remote.git" show \
  refs/heads/automation/kustomize-v0.1.3:k8s/overlays/release/kustomization.yaml | \
  grep -Fq "digest: ${PUBLISHED_IMAGE##*@}"
grep -Fq 'workflow run kubernetes-validation.yml' "$GH_MOCK_LOG"

echo 'PASS: Offline PR automation fixture and explicit workflow dispatch'
