#!/usr/bin/env bash
set -u

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
OSA_DB_CONTAINER="${OSA_DB_CONTAINER:-demo_osrc_23ai}"
SPARK_WORKER_INSTANCES="${SPARK_WORKER_INSTANCES:-2}"
SPARK_WORKER_CORES="${SPARK_WORKER_CORES:-6}"
SPARK_WORKER_MEMORY="${SPARK_WORKER_MEMORY:-7g}"
WAIT_SECONDS="${WAIT_SECONDS:-240}"
OGGBD_CONTAINER="${OGGBD_CONTAINER:-demo_oggbd_23ai}"
KAFKA_REPLICAT_NAME="${KAFKA_REPLICAT_NAME:-KAF01}"

rc=0

ok() { echo "OK: $*"; }
info() { echo "INFO: $*"; }
warn() { echo "WARN: $*"; }
error() { echo "ERROR: $*"; rc=1; }

container_running() {
  [ "$(docker inspect -f '{{.State.Status}}' "$1" 2>/dev/null || true)" = "running" ]
}

start_kafka_replicat() {
  if ! container_running "${OGGBD_CONTAINER}"; then
    warn "${OGGBD_CONTAINER} is not running; skip ${KAFKA_REPLICAT_NAME}"
    return 0
  fi

  echo "==> Ensure ${KAFKA_REPLICAT_NAME} is running"
  docker exec -u ogg "${OGGBD_CONTAINER}" bash -lc "
    timeout 20 curl -fsS 'http://127.0.0.1:8765/api/adminclient?cmd=start%20${KAFKA_REPLICAT_NAME}' >/tmp/fix-osa-start-kaf.out 2>&1 || true
    timeout 20 curl -fsS 'http://127.0.0.1:8765/api/adminclient?cmd=info%20${KAFKA_REPLICAT_NAME}' 2>/dev/null | sed -n '1,20p' || true
  " | sed 's/^/INFO: /'
}

echo "==> Start/repair OSA runtime for dashboard demo"
echo "INFO: OSA_DB_CONTAINER=${OSA_DB_CONTAINER}"
echo "INFO: SPARK_WORKER_INSTANCES=${SPARK_WORKER_INSTANCES}"
echo "INFO: SPARK_WORKER_CORES=${SPARK_WORKER_CORES}"
echo "INFO: SPARK_WORKER_MEMORY=${SPARK_WORKER_MEMORY}"

if [ ! -x "${BASE_DIR}/startOSA.sh" ]; then
  error "startOSA.sh not found in ${BASE_DIR}"
  exit "${rc}"
fi

OSA_DB_CONTAINER="${OSA_DB_CONTAINER}" \
SPARK_WORKER_INSTANCES="${SPARK_WORKER_INSTANCES}" \
SPARK_WORKER_CORES="${SPARK_WORKER_CORES}" \
SPARK_WORKER_MEMORY="${SPARK_WORKER_MEMORY}" \
WAIT_SECONDS="${WAIT_SECONDS}" \
  sh "${BASE_DIR}/startOSA.sh" || error "startOSA.sh failed"

start_kafka_replicat

if [ -x "${BASE_DIR}/chk_osa.sh" ]; then
  echo "==> Post-fix check"
  sh "${BASE_DIR}/chk_osa.sh" || rc=1
fi

echo "INFO: This script does not delete Kafka topics."
echo "INFO: If old Kafka events must be removed for a fresh capture, run reset_osa_demo.sh explicitly."

exit "${rc}"
