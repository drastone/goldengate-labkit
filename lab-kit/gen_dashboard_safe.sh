#!/usr/bin/env bash
set -u

SOURCE_DB_CONTAINER="${SOURCE_DB_CONTAINER:-demo_osrc_23ai}"
SCRIPT_DIR="${SCRIPT_DIR:-/home/oracle/script/osa/23ai}"
COUNT="${1:-20}"
SLEEP_SECONDS="${2:-2}"

rc=0

ok() { echo "OK: $*"; }
info() { echo "INFO: $*"; }
warn() { echo "WARN: $*"; }
error() { echo "ERROR: $*"; rc=1; }

container_running() {
  [ "$(docker inspect -f '{{.State.Status}}' "$1" 2>/dev/null || true)" = "running" ]
}

if ! container_running "${SOURCE_DB_CONTAINER}"; then
  error "${SOURCE_DB_CONTAINER} is not running"
  exit "${rc}"
fi

echo "==> Generate dashboard-safe OSA sample data"
echo "INFO: container=${SOURCE_DB_CONTAINER}"
echo "INFO: script_dir=${SCRIPT_DIR}"
echo "INFO: count=${COUNT}"
echo "INFO: sleep_seconds=${SLEEP_SECONDS}"

docker exec "${SOURCE_DB_CONTAINER}" bash -lc "
  set -u
  cd '${SCRIPT_DIR}' || exit 1

  [ -x ./gen_kill.sh ] || chmod +x ./gen_kill.sh 2>/dev/null || true
  [ -x ./gen_init.sh ] || chmod +x ./gen_init.sh 2>/dev/null || true

  echo 'INFO: stop previous generator loops'
  sh ./gen_kill.sh || true

  echo 'INFO: initialize demo data'
  sh ./gen_init.sh

  run_step() {
    script=\"\$1\"
    label=\"\$2\"
    if [ -f \"\${script}\" ]; then
      echo \"INFO: run \${label}: \${script} ${COUNT} ${SLEEP_SECONDS}\"
      sh \"\${script}\" '${COUNT}' '${SLEEP_SECONDS}'
      sleep 3
    else
      echo \"WARN: missing \${script}; skip \${label}\"
    fi
  }

  run_step ./gen_1.sh 'fund transaction'
  run_step ./gen_3.sh 'cancel transaction'
  run_step ./gen_4.sh 'fund change transaction'
  run_step ./gen_5.sh 'pause transaction'
  run_step ./gen_6.sh 'rejoin transaction'

  if [ -f ./gen_totamt.sh ]; then
    echo 'INFO: refresh total amount summary'
    sh ./gen_totamt.sh 2 2 || true
  fi

  if [ -f ./gen_opstatus.sh ]; then
    echo 'INFO: refresh operation status summary'
    sh ./gen_opstatus.sh 2 2 || true
  fi
"
status=$?
if [ "${status}" -eq 0 ]; then
  ok "dashboard-safe data generation completed"
else
  error "dashboard-safe data generation failed"
fi

exit "${rc}"
