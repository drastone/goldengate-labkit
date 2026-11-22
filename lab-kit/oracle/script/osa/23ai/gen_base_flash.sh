#!/usr/bin/env sh
#
# OSA dashboard flash workload.
#
# Usage:
#   sh gen_base_flash.sh <business_loop_count> <inner_loop_count>
#
# Example:
#   sh gen_base_flash.sh 100 1
#
# This mode is intentionally optimized for screen recording and dashboard
# movement. It runs business generators in parallel like the original demo
# script, so use gen_base.sh for the book's business-consistent lab flow.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

BUSINESS_LOOPS="${1:-100}"
INNER_LOOPS="${2:-1}"
BASE_MONTHS="${GEN_BASE_MONTHS:-60}"
BASE_WARMUP_SECONDS="${GEN_BASE_WARMUP_SECONDS:-15}"
MONITOR_LOOPS="${GEN_MONITOR_LOOPS:-720}"
MONITOR_SLEEP="${GEN_MONITOR_SLEEP:-2}"

export GEN_SKIP_DAILY_CLEAR=Y
export GEN_SLEEP_GEN1="${GEN_SLEEP_GEN1:-2}"
export GEN_SLEEP_GEN3="${GEN_SLEEP_GEN3:-2}"
export GEN_SLEEP_GEN4="${GEN_SLEEP_GEN4:-2}"
export GEN_SLEEP_GEN5="${GEN_SLEEP_GEN5:-2}"
export GEN_SLEEP_GEN6="${GEN_SLEEP_GEN6:-2}"

start_bg() {
  label="$1"
  shift
  script="$1"
  shift
  log_file="nohup_flash_${script%.sh}.out"

  printf '[%s] FLASH START %-28s %s %s -> %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$label" "$script" "$*" "$log_file"
  nohup sh "$script" "$@" > "$log_file" 2>&1 &
}

printf '[%s] FLASH initialize: kill old generator sessions\n' "$(date '+%Y-%m-%d %H:%M:%S')"
sh gen_kill.sh

printf '[%s] FLASH initialize: reset demo data\n' "$(date '+%Y-%m-%d %H:%M:%S')"
sh gen_init.sh

start_bg "regular premium base data" gen_0.sh "$BASE_MONTHS"
sleep "$BASE_WARMUP_SECONDS"

start_bg "additional premium" gen_1.sh "$BUSINESS_LOOPS" "$INNER_LOOPS"
start_bg "partial withdrawal" gen_3.sh "$BUSINESS_LOOPS" "$INNER_LOOPS"
start_bg "fund change" gen_4.sh "$BUSINESS_LOOPS" "$INNER_LOOPS"
start_bg "cancellation" gen_5.sh "$BUSINESS_LOOPS" "$INNER_LOOPS"
start_bg "new business" gen_6.sh "$BUSINESS_LOOPS" "$INNER_LOOPS"

start_bg "transaction status" gen_opstatus.sh "$MONITOR_LOOPS" "$MONITOR_SLEEP"
start_bg "total fund amount" gen_totamt.sh "$MONITOR_LOOPS" "$MONITOR_SLEEP"
start_bg "heartbeat period" gen_heartbp.sh "$MONITOR_LOOPS" "$MONITOR_SLEEP"

printf '[%s] gen_base_flash.sh started. business_loops=%s inner_loops=%s base_months=%s monitor_sleep=%s\n' \
  "$(date '+%Y-%m-%d %H:%M:%S')" "$BUSINESS_LOOPS" "$INNER_LOOPS" "$BASE_MONTHS" "$MONITOR_SLEEP"
