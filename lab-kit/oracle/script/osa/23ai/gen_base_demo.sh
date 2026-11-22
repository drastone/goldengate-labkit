#!/usr/bin/env sh
#
# Dashboard-friendly workload mode.
#
# Usage:
#   sh gen_base_demo.sh <business_loop_count> <inner_loop_count>
#
# Example:
#   sh gen_base_demo.sh 30 1
#
# This keeps the business generators sequential, but shortens sleeps so OSA
# dashboards receive visibly changing data during demos and screen recording.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

export GEN_MONITOR_SLEEP="${GEN_MONITOR_SLEEP:-2}"
export GEN_SLEEP_GEN1="${GEN_SLEEP_GEN1:-3}"
export GEN_SLEEP_GEN3="${GEN_SLEEP_GEN3:-2}"
export GEN_SLEEP_GEN4="${GEN_SLEEP_GEN4:-2}"
export GEN_SLEEP_GEN5="${GEN_SLEEP_GEN5:-3}"
export GEN_SLEEP_GEN6="${GEN_SLEEP_GEN6:-2}"

exec sh gen_base.sh "${1:-30}" "${2:-1}"
