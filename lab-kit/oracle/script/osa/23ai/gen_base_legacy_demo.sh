#!/usr/bin/env sh
#
# Legacy visual demo workload.
#
# Usage:
#   sh gen_base_legacy_demo.sh <business_loop_count> <inner_loop_count>
#
# Example:
#   sh gen_base_legacy_demo.sh 100 1
#
# This script preserves the original visually active demo behavior. It runs
# multiple workload generators in parallel and intentionally does not set
# GEN_SKIP_DAILY_CLEAR, so gen_1.sh keeps its original same-day delete/insert
# pattern. Use this for OSA screen recording only. Use gen_base.sh for the
# business-consistent book/lab flow.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

BUSINESS_LOOPS="${1:-100}"
INNER_LOOPS="${2:-1}"

sh gen_kill.sh
sh gen_init.sh

nohup sh gen_0.sh 60 &
sleep 15

nohup sh gen_1.sh "$BUSINESS_LOOPS" "$INNER_LOOPS" &
nohup sh gen_3.sh "$BUSINESS_LOOPS" "$INNER_LOOPS" &
nohup sh gen_4.sh "$BUSINESS_LOOPS" "$INNER_LOOPS" &
nohup sh gen_5.sh "$BUSINESS_LOOPS" "$INNER_LOOPS" &
nohup sh gen_6.sh "$BUSINESS_LOOPS" "$INNER_LOOPS" &

nohup sh gen_opstatus.sh 720 12 &
nohup sh gen_totamt.sh 720 12 &
nohup sh gen_heartbp.sh 720 12 &
