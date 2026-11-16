#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ] || shopt -qo posix 2>/dev/null; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  fi
  echo "ERROR: lab11_init.sh requires bash." >&2
  exit 1
fi

set -Eeuo pipefail

LAB11_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGURE_TRAIL_PURGE="${CONFIGURE_TRAIL_PURGE:-${LAB11_DIR}/../../oracle/script/restapi-lab/configure_trail_purge.sh}"

if [ ! -f "${CONFIGURE_TRAIL_PURGE}" ]; then
  echo "ERROR: Chapter 11 trail-purge setup was not found: ${CONFIGURE_TRAIL_PURGE}" >&2
  exit 1
fi

echo "INFO: Chapter 11 compatibility entry point; delegating to ${CONFIGURE_TRAIL_PURGE}"
exec bash "${CONFIGURE_TRAIL_PURGE}" "$@"
