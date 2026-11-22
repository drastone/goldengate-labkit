#!/usr/bin/env sh
#
# Business-consistent workload generator.
#
# Usage:
#   sh gen_base_consistent.sh <business_loop_count> <inner_loop_count>
#
# Example:
#   sh gen_base_consistent.sh 100 1
#
# The business event generators run sequentially. This avoids invalid demo
# ordering such as a cancelled customer receiving a later premium event from a
# concurrently running generator.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

BUSINESS_LOOPS="${1:-100}"
INNER_LOOPS="${2:-1}"
BASE_MONTHS="${GEN_BASE_MONTHS:-60}"
MONITOR_LOOPS="${GEN_MONITOR_LOOPS:-720}"
MONITOR_SLEEP="${GEN_MONITOR_SLEEP:-12}"
ENABLE_MONITORS="${GEN_ENABLE_MONITORS:-Y}"

run_step() {
  label="$1"
  shift
  script="$1"
  shift

  printf '\n[%s] START %s: %s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$label" "$script" "$*"
  sh "$script" "$@"
  printf '[%s] END   %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$label"
}

start_monitor() {
  label="$1"
  shift
  script="$1"
  shift
  log_file="nohup_${script%.sh}.out"

  printf '[%s] MONITOR START %s: %s %s -> %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$label" "$script" "$*" "$log_file"
  nohup sh "$script" "$@" > "$log_file" 2>&1 &
}

# 기존 세션 정리 및 초기화
run_step "kill old generator sessions" gen_kill.sh
run_step "initialize demo data" gen_init.sh

# 기준 데이터 생성: 정기 납입 이력
run_step "regular premium base data" gen_0.sh "$BASE_MONTHS"

# OSA 화면 관측용 집계/heartbeat는 업무 이벤트와 독립적으로 백그라운드 실행
if [ "$ENABLE_MONITORS" = "Y" ]; then
  start_monitor "transaction status" gen_opstatus.sh "$MONITOR_LOOPS" "$MONITOR_SLEEP"
  start_monitor "total fund amount" gen_totamt.sh "$MONITOR_LOOPS" "$MONITOR_SLEEP"
  start_monitor "heartbeat period" gen_heartbp.sh "$MONITOR_LOOPS" "$MONITOR_SLEEP"
fi

# 업무 이벤트는 순차 실행한다.
# 해약은 terminal 성격이 강하므로 납입/인출/펀드변경 이후에 수행한다.
export GEN_SKIP_DAILY_CLEAR=Y
run_step "additional premium" gen_1.sh "$BUSINESS_LOOPS" "$INNER_LOOPS"
run_step "partial withdrawal" gen_3.sh "$BUSINESS_LOOPS" "$INNER_LOOPS"
run_step "fund change" gen_4.sh "$BUSINESS_LOOPS" "$INNER_LOOPS"
run_step "cancellation" gen_5.sh "$BUSINESS_LOOPS" "$INNER_LOOPS"
run_step "new business" gen_6.sh "$BUSINESS_LOOPS" "$INNER_LOOPS"

printf '\n[%s] gen_base_consistent.sh completed. business_loops=%s inner_loops=%s base_months=%s\n' \
  "$(date '+%Y-%m-%d %H:%M:%S')" "$BUSINESS_LOOPS" "$INNER_LOOPS" "$BASE_MONTHS"
