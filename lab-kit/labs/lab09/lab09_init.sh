#!/usr/bin/env bash
set -eu

# Prepare only the optional Lakehouse services needed by the Chapter 9 lab.
# The Kafka-Iceberg writer remains opt-in so no Kafka records are consumed yet.

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_HOME="${LAB_HOME:-$(cd "${LAB_DIR}/../.." && pwd)}"
START_LAKEHOUSE="${START_LAKEHOUSE:-${LAB_HOME}/startLakehouse.sh}"
DOCKER_NETWORK="${DOCKER_NETWORK:-oracle_ogg_network}"
MINIO_BUCKET="${MINIO_BUCKET:-warehouse}"
MINIO_MC="/opt/bitnami/minio-client/bin/mc"
MINIO_ROOT_USER="${MINIO_ROOT_USER:-admin}"
MINIO_ROOT_PASSWORD="${MINIO_ROOT_PASSWORD:-WElcome1234##}"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $1" >&2
    exit 1
  fi
}

wait_for_url() {
  local name="$1"
  local url="$2"
  local attempt

  for attempt in $(seq 1 12); do
    if curl --max-time 5 -fsS "${url}" >/dev/null; then
      echo "OK: ${name} is ready: ${url}"
      return 0
    fi
    sleep 5
  done

  echo "ERROR: ${name} did not become ready: ${url}" >&2
  return 1
}

require_command docker
require_command curl

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker is not running. Start Docker before this lab." >&2
  exit 1
fi

if ! docker network inspect "${DOCKER_NETWORK}" >/dev/null 2>&1; then
  echo "ERROR: Docker network not found: ${DOCKER_NETWORK}" >&2
  echo "Run /home/oracle/startDocker.sh before starting this lab." >&2
  exit 1
fi

if [ ! -x "${START_LAKEHOUSE}" ]; then
  echo "ERROR: Lakehouse startup script not found or not executable: ${START_LAKEHOUSE}" >&2
  exit 1
fi

echo "==> Chapter 9 Lakehouse initialization"
echo "INFO: Start only MinIO and Iceberg REST Catalog."
echo "INFO: Trino remains optional to reduce memory usage."
echo "INFO: Kafka-Iceberg writer remains stopped until the writer step."

LAB_HOME="${LAB_HOME}" "${START_LAKEHOUSE}"

echo "==> Verify Lakehouse service readiness"
wait_for_url "MinIO" "http://127.0.0.1:38900/minio/health/live"
wait_for_url "Iceberg REST Catalog" "http://127.0.0.1:38181/v1/config"

if ! docker exec demo_minio "${MINIO_MC}" alias set lab http://127.0.0.1:9000 \
  "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}" >/dev/null 2>&1; then
  echo "ERROR: MinIO client could not connect to the local server." >&2
  exit 1
fi

if docker exec demo_minio "${MINIO_MC}" stat "lab/${MINIO_BUCKET}" >/dev/null 2>&1; then
  echo "OK: Required MinIO bucket already exists: ${MINIO_BUCKET}"
else
  echo "INFO: Required MinIO bucket was not found: ${MINIO_BUCKET}"
  echo "==> Create MinIO bucket: ${MINIO_BUCKET}"
  if ! docker exec demo_minio "${MINIO_MC}" mb "lab/${MINIO_BUCKET}" >/dev/null 2>&1; then
    echo "ERROR: MinIO bucket could not be created: ${MINIO_BUCKET}" >&2
    echo "Check the MinIO log: docker logs --tail 80 demo_minio" >&2
    exit 1
  fi
  echo "OK: MinIO bucket was created: ${MINIO_BUCKET}"
fi

if docker exec demo_minio "${MINIO_MC}" stat "lab/${MINIO_BUCKET}" >/dev/null 2>&1; then
  echo "OK: MinIO bucket is ready: ${MINIO_BUCKET}"
else
  echo "ERROR: MinIO bucket is not ready: ${MINIO_BUCKET}" >&2
  exit 1
fi

echo "==> Lakehouse containers"
docker ps \
  --filter name=demo_minio \
  --filter name=demo_iceberg_catalog \
  --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

if docker ps --format '{{.Names}}' | grep -qx 'demo_kafka_iceberg_writer'; then
  echo "WARN: demo_kafka_iceberg_writer is already running."
  echo "WARN: It may consume Kafka records before the writer step."
  echo "INFO: This initialization script leaves the running writer unchanged."
else
  echo "OK: demo_kafka_iceberg_writer is not running yet."
  echo "NEXT: Continue with the Kafka-Iceberg Writer setup in this chapter."
fi

echo "OK: Chapter 9 Lakehouse initialization completed."
