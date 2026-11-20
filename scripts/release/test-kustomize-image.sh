#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

image='ghcr.io/maxvanny2010/atu-devops-pipeline'
old="sha256:$(printf 'a%.0s' {1..64})"
new="sha256:$(printf 'b%.0s' {1..64})"
file="$tmp/kustomization.yaml"

cat > "$file" <<YAML
images:
  - name: task-manager
    newName: $image
    digest: $old
YAML

bash "$root/update-kustomize-image.sh" "$image@$new" "$file"
grep -Fqx "    digest: $new" "$file"

before="$(sha256sum "$file")"
bash "$root/update-kustomize-image.sh" "$image@$new" "$file"
[[ "$before" == "$(sha256sum "$file")" ]]

if bash "$root/update-kustomize-image.sh" \
  "$image@sha256:bad" "$file"; then
  echo 'FAIL: Invalid digest accepted' >&2
  exit 1
fi

if bash "$root/update-kustomize-image.sh" \
  "$image@$old" "$tmp/missing"; then
  echo 'FAIL: Missing file accepted' >&2
  exit 1
fi

printf '    newTag: v0.1.1\n' >> "$file"

if bash "$root/update-kustomize-image.sh" \
  "$image@$old" "$file"; then
  echo 'FAIL: Ambiguous version accepted' >&2
  exit 1
fi

cat > "$file" <<YAML
images:
  - name: task-manager
    newName: $image
    newTag: v0.1.2
YAML

bash "$root/update-kustomize-image.sh" "$image@$new" "$file"
grep -Fqx "    digest: $new" "$file"
! grep -q newTag "$file"

echo 'PASS: digest update and negative tests'
