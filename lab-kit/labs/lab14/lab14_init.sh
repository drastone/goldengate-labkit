#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ] || shopt -qo posix 2>/dev/null; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  fi
  echo "ERROR: lab14_init.sh requires bash." >&2
  exit 1
fi

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_HOME="${LAB_HOME:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"
LAB_LOGGING="${LAB_HOME}/troubleshooting/scripts/lab_init_logging.sh"
LAB12_INIT="${SCRIPT_DIR}/../lab12/lab12_configure_source_apps.sh"

if [ ! -f "${LAB_LOGGING}" ]; then
  echo "ERROR: shared Lab logging helper not found: ${LAB_LOGGING}" >&2
  exit 1
fi
source "${LAB_LOGGING}"
lab_init_log_begin lab14 lab14-init

if [ ! -f "${LAB12_INIT}" ]; then
  echo "ERROR: shared Source application initializer not found: ${LAB12_INIT}" >&2
  exit 1
fi

bash "${LAB12_INIT}" "$@"
lab_init_log_finish
