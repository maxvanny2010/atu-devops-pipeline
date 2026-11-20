#!/usr/bin/env bash
set -Eeuo pipefail

if ! command -v kubectl >/dev/null 2>&1; then
  echo "FAIL: kubectl is not available"
  exit 1
fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

release_manifest="${workdir}/release.yaml"
kubectl kustomize k8s/overlays/release > "$release_manifest"

mapfile -t expected_images < <(
  awk '$1 == "-" && $2 == "image:" { print $3 }' "$release_manifest"
)

if [[ "${#expected_images[@]}" -ne 1 ]]; then
  echo "FAIL: Expected exactly one release image"
  exit 1
fi

expected_image="${expected_images[0]}"

if [[ "$expected_image" != ghcr.io/*:* ]]; then
  echo "FAIL: Invalid release image: $expected_image"
  exit 1
fi

echo "Expected release image: $expected_image"

for environment in local prod; do
  echo "=== Validating ${environment} ==="

  manifest="${workdir}/${environment}.yaml"
  kubectl kustomize "k8s/overlays/${environment}" > "$manifest"

  mapfile -t actual_images < <(
    awk '$1 == "-" && $2 == "image:" { print $3 }' "$manifest"
  )

  if [[ "${#actual_images[@]}" -ne 1 ]]; then
    echo "FAIL: Expected one image in ${environment}"
    exit 1
  fi

  if [[ "${actual_images[0]}" != "$expected_image" ]]; then
    echo "FAIL: Image mismatch in ${environment}"
    exit 1
  fi

  grep -Eq '^[[:space:]]*replicas: 1$' "$manifest"
  grep -Fq 'kind: Deployment' "$manifest"
  grep -Fq 'kind: Service' "$manifest"
  grep -Fq 'runAsNonRoot: true' "$manifest"
  grep -Fq 'readOnlyRootFilesystem: true' "$manifest"
  grep -Fq 'allowPrivilegeEscalation: false' "$manifest"
  grep -Fq 'type: RuntimeDefault' "$manifest"
  grep -Fq 'startupProbe:' "$manifest"
  grep -Fq 'readinessProbe:' "$manifest"
  grep -Fq 'livenessProbe:' "$manifest"

  echo "PASS: ${environment}"
done

echo "PASS: Kubernetes manifest validation completed"
