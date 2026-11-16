#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
LAB12_INIT="${SCRIPT_DIR}/../lab12/lab12_configure_source_apps.sh"

if [ ! -f "${LAB12_INIT}" ]; then
  echo "ERROR: shared Source application initializer not found: ${LAB12_INIT}" >&2
  exit 1
fi

exec bash "${LAB12_INIT}" "$@"
