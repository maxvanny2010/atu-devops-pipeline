#!/usr/bin/env bash
set -euo pipefail

: "${APP_PORT:?APP_PORT is required}"
max_attempts="${HEALTH_ATTEMPTS:-60}"
delay="${HEALTH_DELAY_SECONDS:-2}"
[[ "$max_attempts" =~ ^[1-9][0-9]*$ ]] || { echo 'Invalid HEALTH_ATTEMPTS' >&2; exit 1; }
[[ "$delay" =~ ^[1-9][0-9]*$ ]] || { echo 'Invalid HEALTH_DELAY_SECONDS' >&2; exit 1; }

for ((attempt=1; attempt<=max_attempts; attempt++)); do
  if curl --fail --silent --max-time 2     "http://127.0.0.1:${APP_PORT}/actuator/health" > /dev/null; then
    echo 'Application ready.'
    exit 0
  fi
  if (( attempt < max_attempts )); then sleep "$delay"; fi
done

if [[ -f spring-boot.log ]]; then cat spring-boot.log >&2; fi
echo 'Application health check timed out.' >&2
exit 1
