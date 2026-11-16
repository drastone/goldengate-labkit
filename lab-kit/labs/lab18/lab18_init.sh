#!/bin/sh

set -eu

LAB18_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
LAB18_MAIN="${LAB18_DIR}/lab18_init.bash"

if ! command -v bash >/dev/null 2>&1; then
  echo "ERROR: lab18_init.sh requires bash." >&2
  exit 1
fi
if [ ! -f "${LAB18_MAIN}" ]; then
  echo "ERROR: Lab 18 Bash entry point not found: ${LAB18_MAIN}" >&2
  exit 1
fi

exec bash "${LAB18_MAIN}" "$@"
