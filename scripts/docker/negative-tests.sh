#!/usr/bin/env bash
set -Eeuo pipefail

SMOKE_SCRIPT="scripts/docker/smoke-test.sh"

if [[ ! -f "$SMOKE_SCRIPT" ]]; then
  echo "FAIL: Missing smoke-test script"
  exit 1
fi

run_negative() {
  local label="$1"
  local input="$2"
  local expected_exit="$3"
  local expected_error="$4"
  shift 4

  local output
  local actual_exit=0

  echo
  echo "=== TEST: $label ==="
  echo "Input: $input"
  echo "Expected exit code: $expected_exit"

  output="$("$@" 2>&1)" || actual_exit=$?

  echo "Actual exit code: $actual_exit"

  if [[ "$actual_exit" -ne "$expected_exit" ]]; then
    echo "FAIL: Unexpected exit code"
    printf '%s\n' "$output" | tail -n 12
    return 1
  fi

  if [[ "$output" != *"$expected_error"* ]]; then
    echo "FAIL: Expected error not detected"
    printf '%s\n' "$output" | tail -n 12
    return 1
  fi

  echo "Observed error:"
  while IFS= read -r line; do
    if [[ "$line" == *"$expected_error"* ]]; then
      printf '  %s\n' "$line"
    fi
  done <<< "$output"

  echo "PASS: $label correctly rejected"
}

echo "=== NEGATIVE DOCKER RUNTIME TESTS ==="

run_negative \
  "Incorrect UID" \
  "APP_UID=10002 (image user is 10001:10001)" \
  1 \
  "FAIL: Image user" \
  env APP_UID=10002 bash "$SMOKE_SCRIPT"

run_negative \
  "Invalid container port" \
  "CONTAINER_PORT=0" \
  1 \
  "FAIL: Invalid port or timeout" \
  env CONTAINER_PORT=0 bash "$SMOKE_SCRIPT"

run_negative \
  "Nonexistent REST API endpoint" \
  "API_PATH=/api/__negative_test_missing__" \
  22 \
  "curl: (22)" \
  env API_PATH=/api/__negative_test_missing__ \
  bash "$SMOKE_SCRIPT"

echo
echo "PASS: All 3 negative Docker runtime tests completed"
