#!/usr/bin/env bash
set -u

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DB_CONTAINER="${SOURCE_DB_CONTAINER:-demo_osrc_23ai}"
SCRIPT_DIR="${SCRIPT_DIR:-/home/oracle/script/osa/23ai}"
GEN_COUNT="${1:-10}"
GEN_SLEEP="${2:-1}"

rc=0

ok() { echo "OK: $*"; }
info() { echo "INFO: $*"; }
warn() { echo "WARN: $*"; }
error() { echo "ERROR: $*"; rc=1; }

run_step() {
  title="$1"
  shift
  echo "==> ${title}"
  "$@" || {
    error "${title} failed"
    exit "${rc}"
  }
}

echo "==> Recover OSA dashboard demo"
echo "INFO: This script is for the bad state where the source Kafka topic grows,"
echo "INFO: but OSA dashboard output topics do not grow."
echo "INFO: reset_osa_demo.sh will ask for RESET before deleting demo Kafka topics."
echo "INFO: generator command will be: sh gen_base.sh ${GEN_COUNT} ${GEN_SLEEP}"

run_step "Check current OSA/Kafka state" sh "${BASE_DIR}/chk_osa.sh"
run_step "Reset OSA demo Kafka topics" sh "${BASE_DIR}/reset_osa_demo.sh"
run_step "Repair/start OSA runtime" sh "${BASE_DIR}/fix_osa_demo.sh"

echo "==> Send dashboard demo data"
docker exec "${SOURCE_DB_CONTAINER}" bash -lc "
  cd '${SCRIPT_DIR}' &&
  sh gen_base.sh '${GEN_COUNT}' '${GEN_SLEEP}'
" || {
  error "gen_base.sh failed"
  exit "${rc}"
}
ok "gen_base.sh ${GEN_COUNT} ${GEN_SLEEP} completed"

echo "==> Wait briefly for OSA output topics"
sleep 20

run_step "Check final OSA/Kafka state" sh "${BASE_DIR}/chk_osa.sh"

echo "INFO: Expected healthy result:"
echo "INFO:   SOE.CFUND_DT grows, and sx_KafkaPipeline_* output topics also grow."

exit "${rc}"
