#!/usr/bin/env bash
set -Eeuo pipefail

# Prevent Git Bash from translating Linux container paths on Windows.
export MSYS_NO_PATHCONV=1

IMAGE_NAME="${IMAGE_NAME:-atu-task-manager:ci}"
HOST_IP="127.0.0.1"
CONTAINER_PORT="${CONTAINER_PORT:-8080}"
STARTUP_TIMEOUT="${STARTUP_TIMEOUT:-120}"
HEALTH_PATH="${HEALTH_PATH:-/actuator/health}"
API_PATH="${API_PATH:-/api/tasks}"
APP_UID="${APP_UID:-10001}"
APP_GID="${APP_GID:-10001}"

for tool in docker curl grep; do
  command -v "$tool" >/dev/null || {
    echo "FAIL: Required tool unavailable: $tool"
    exit 1
  }
done

for value in "$CONTAINER_PORT" "$STARTUP_TIMEOUT" "$APP_UID" "$APP_GID"; do
  [[ "$value" =~ ^[0-9]+$ ]] || {
    echo "FAIL: Invalid numeric configuration: $value"
    exit 1
  }
done

if (( 10#$CONTAINER_PORT < 1 || 10#$CONTAINER_PORT > 65535 ||
      10#$STARTUP_TIMEOUT < 1 )); then
  echo "FAIL: Invalid port or timeout"
  exit 1
fi

[[ "$HEALTH_PATH" == /* && "$API_PATH" == /* ]] || {
  echo "FAIL: Invalid endpoint path"
  exit 1
}

container_name="atu-smoke-${RANDOM}-$$"

cleanup() {
  result=$?

  if (( result != 0 )); then
    echo "FAIL: Docker smoke test (exit $result)"
    docker logs "$container_name" 2>&1 || true
  fi

  docker rm -f "$container_name" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "=== VERIFY IMAGE USER ==="

actual_user="$(docker image inspect \
  --format '{{.Config.User}}' "$IMAGE_NAME")"

expected_user="${APP_UID}:${APP_GID}"

[[ "$actual_user" == "$expected_user" ]] || {
  echo "FAIL: Image user $actual_user; expected $expected_user"
  exit 1
}

echo "PASS: Non-root image user"

echo "=== START SECURE CONTAINER ==="

docker run -d \
  --name "$container_name" \
  --read-only \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --tmpfs "/app/tmp:rw,nosuid,noexec,size=64m,uid=${APP_UID},gid=${APP_GID}" \
  -p "${HOST_IP}::${CONTAINER_PORT}" \
  "$IMAGE_NAME" >/dev/null

echo "=== VERIFY SECURITY CONTRACT ==="

readonly_root="$(docker inspect \
  --format '{{.HostConfig.ReadonlyRootfs}}' "$container_name")"

cap_drop="$(docker inspect \
  --format '{{range .HostConfig.CapDrop}}{{.}} {{end}}' "$container_name")"

security_options="$(docker inspect \
  --format '{{range .HostConfig.SecurityOpt}}{{.}} {{end}}' "$container_name")"

tmpfs_options="$(docker inspect \
  --format '{{index .HostConfig.Tmpfs "/app/tmp"}}' "$container_name")"

[[ "$readonly_root" == "true" ]] || {
  echo "FAIL: Writable root filesystem"
  exit 1
}

[[ " ${cap_drop^^} " == *" ALL "* ]] || {
  echo "FAIL: Linux capabilities were not dropped"
  exit 1
}

[[ " $security_options " == *" no-new-privileges "* ]] || {
  echo "FAIL: Privilege escalation restriction missing"
  exit 1
}

for option in "rw" "nosuid" "noexec" "uid=$APP_UID" "gid=$APP_GID"; do
  [[ ",$tmpfs_options," == *",$option,"* ]] || {
    echo "FAIL: Missing tmpfs option: $option"
    exit 1
  }
done

echo "PASS: Container security contract"

echo "=== DISCOVER DYNAMIC HOST PORT ==="

published="$(docker port "$container_name" "${CONTAINER_PORT}/tcp")"

if [[ ! "$published" =~ ^127\.0\.0\.1:([0-9]+)$ ]]; then
  echo "FAIL: Unexpected published address: $published"
  exit 1
fi

host_port="${BASH_REMATCH[1]}"
base_url="http://${HOST_IP}:${host_port}"

echo "=== VERIFY APPLICATION HEALTH ==="

started=$SECONDS

while true; do
  if response="$(curl -fsS --max-time 3 \
      "${base_url}${HEALTH_PATH}" 2>/dev/null)"; then

    if printf '%s' "$response" |
       grep -Eq '"status"[[:space:]]*:[[:space:]]*"UP"'; then
      echo "PASS: Spring Boot health UP"
      break
    fi
  fi

  running="$(docker inspect \
    --format '{{.State.Running}}' "$container_name")"

  [[ "$running" == "true" ]] || {
    echo "FAIL: Container stopped unexpectedly"
    exit 1
  }

  if (( SECONDS - started >= STARTUP_TIMEOUT )); then
    echo "FAIL: Health check timeout"
    exit 1
  fi

  sleep 2
done

echo "=== VERIFY REST API ==="

api_response="$(curl -fsS --max-time 10 \
  "${base_url}${API_PATH}")"

if ! printf '%s' "$api_response" |
     grep -Eq '^[[:space:]]*\['; then
  echo "FAIL: GET /api/tasks did not return a JSON array"
  exit 1
fi

echo "PASS: GET /api/tasks responded"
echo "=== VERIFY FRONTEND ==="

for path in "/" "/index.html" "/styles.css" "/app.js"; do
  if ! curl -fsS --max-time 10 "${base_url}${path}" >/dev/null; then
    echo "FAIL: Frontend request failed: $path"
    exit 1
  fi

  echo "PASS: Frontend $path returned HTTP 200"
done
echo "PASS: Docker runtime smoke test completed"
