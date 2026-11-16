#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ] || shopt -qo posix 2>/dev/null; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  fi
  echo "ERROR: lab13_init.sh requires bash." >&2
  exit 1
fi

set -Eeuo pipefail

LAB13_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB12_INIT="${LAB12_INIT:-${LAB13_DIR}/../lab12/lab12_init.sh}"

if [ ! -f "${LAB12_INIT}" ]; then
  echo "ERROR: APEX/ORDS setup entry point not found: ${LAB12_INIT}" >&2
  exit 1
fi

echo "INFO: Chapter 13 compatibility entry point; delegating to ${LAB12_INIT}"
exec bash "${LAB12_INIT}" "$@"
