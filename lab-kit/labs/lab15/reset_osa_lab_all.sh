#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

echo "INFO: reset_osa_lab_all.sh is kept for compatibility."
echo "INFO: Use /home/oracle/labs/reset_lab_all.sh for the integrated lab reset flow."

exec "${SCRIPT_DIR}/../reset_lab_all.sh" "$@"
