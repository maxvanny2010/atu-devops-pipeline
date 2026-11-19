#!/usr/bin/env bash
set -euo pipefail

mapfile -t JARS < <(find target -maxdepth 1 -type f \
  -name '*.jar' ! -name '*.jar.original' | sort)
if (( ${#JARS[@]} != 1 )); then
  printf 'Expected one application JAR; found %s\n' "${#JARS[@]}" >&2
  exit 1
fi
java -jar "${JARS[0]}" \
  --server.port="$APP_PORT" > spring-boot.log 2>&1 &
