#!/usr/bin/env bash
set -Eeuo pipefail

VERSION="${KUBECTL_VERSION:-v1.36.1}"
BASE="https://dl.k8s.io/release/${VERSION}/bin/linux/amd64"

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "FAIL: kubectl installer requires Linux"
  exit 1
fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

curl --fail --location --retry 3 \
  --output "${workdir}/kubectl" "${BASE}/kubectl"

curl --fail --location --retry 3 \
  --output "${workdir}/kubectl.sha256" "${BASE}/kubectl.sha256"

(
  cd "$workdir"
  echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
)

sudo install -m 0755 "${workdir}/kubectl" /usr/local/bin/kubectl

kubectl version --client
