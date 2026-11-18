#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ] || shopt -qo posix 2>/dev/null; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  fi
  echo "ERROR: lab10_init.sh requires bash." >&2
  exit 1
fi

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_HOME="${LAB_HOME:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"

LAB_LOG_NAME=lab10 LAB_LOG_STAGE=lab10-init \
  bash "${SCRIPT_DIR}/../lab09/lab09_init.sh" "$@"
