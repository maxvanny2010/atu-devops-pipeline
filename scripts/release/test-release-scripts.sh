#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

root="$PWD"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"
cat > "$tmp/bin/gh" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "${MOCK_MASTER_SHA:-abc123}"
EOF
chmod +x "$tmp/bin/gh"
export PATH="$tmp/bin:$PATH"
export GITHUB_REPOSITORY='owner/repo' GITHUB_SERVER_URL='https://github.com'
export GITHUB_SHA='abc123' GITHUB_REF_NAME='v0.1.0'

bash scripts/release/validate-tag.sh
if GITHUB_REF_NAME='v0.1.0-rc1' bash scripts/release/validate-tag.sh >/dev/null 2>&1; then
  echo 'FAIL: invalid tag accepted' >&2; exit 1
fi
if MOCK_MASTER_SHA='wrong' bash scripts/release/validate-tag.sh >/dev/null 2>&1; then
  echo 'FAIL: non-master commit accepted' >&2; exit 1
fi

cat > "$tmp/bin/docker" <<'EOF'
#!/usr/bin/env bash
case "$*" in
  *image\ inspect* )
    case "$*" in
      *org.opencontainers.image.revision*) echo "${MOCK_REVISION:-abc123}" ;;
      *org.opencontainers.image.source*) echo "${MOCK_SOURCE:-https://github.com/owner/repo}" ;;
      *) echo 'sha256:original-image-id' ;;
    esac ;;
  load) cat >/dev/null ;;
  buildx\ imagetools\ inspect*)
    if [[ "${MOCK_TAG_EXISTS:-0}" == 1 ]]; then exit 0; fi
    echo 'manifest unknown' >&2
    exit 1 ;;
  *) echo "Unexpected docker call: $*" >&2; exit 1 ;;
esac
EOF
chmod +x "$tmp/bin/docker"
cat > "$tmp/bin/curl" <<'EOF'
#!/usr/bin/env bash
printf '%s' "${MOCK_HTTP_CODE:-404}"
EOF
chmod +x "$tmp/bin/curl"
export GH_TOKEN='offline-fake-token'
bash scripts/release/check-release-targets.sh
if MOCK_HTTP_CODE='200' bash scripts/release/check-release-targets.sh >/dev/null 2>&1; then
  echo 'FAIL: existing release accepted' >&2; exit 1
fi
if MOCK_HTTP_CODE='403' bash scripts/release/check-release-targets.sh >/dev/null 2>&1; then
  echo 'FAIL: API failure accepted' >&2; exit 1
fi
if MOCK_TAG_EXISTS='1' bash scripts/release/check-release-targets.sh >/dev/null 2>&1; then
  echo 'FAIL: existing container tag accepted' >&2; exit 1
fi
mkdir -p "$tmp/work"
cd "$tmp/work"
printf 'sha256:original-image-id\n' > release-image-id.txt
printf 'not-an-actual-docker-archive\n' | gzip > release-image.tar.gz
sha256sum release-image.tar.gz release-image-id.txt > release-image.sha256
export CANDIDATE_IMAGE='atu-task-manager:release-candidate'
bash "$root/scripts/release/load-image.sh"
if MOCK_REVISION='wrong' bash "$root/scripts/release/load-image.sh" >/dev/null 2>&1; then
  echo 'FAIL: wrong revision accepted' >&2; exit 1
fi
if MOCK_SOURCE='https://github.com/other/repo' bash "$root/scripts/release/load-image.sh" >/dev/null 2>&1; then
  echo 'FAIL: wrong source accepted' >&2; exit 1
fi
printf 'tamper' >> release-image.tar.gz
if bash "$root/scripts/release/load-image.sh" >/dev/null 2>&1; then
  echo 'FAIL: corrupt archive accepted' >&2; exit 1
fi

echo 'Release offline tests: PASS (tag, master, GHCR preflight, metadata, checksum)'
