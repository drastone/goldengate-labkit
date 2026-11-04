#!/usr/bin/env bash
set -eu

# Prepare only the optional Lakehouse services needed by the Chapter 9 lab.
# The Kafka-Iceberg writer remains opt-in so no Kafka records are consumed yet.

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_HOME="${LAB_HOME:-$(cd "${LAB_DIR}/../.." && pwd)}"
START_LAKEHOUSE="${START_LAKEHOUSE:-${LAB_HOME}/startLakehouse.sh}"
DOCKER_NETWORK="${DOCKER_NETWORK:-oracle_ogg_network}"

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
echo "INFO: Start only MinIO, Iceberg REST Catalog, and Trino."
echo "INFO: Kafka-Iceberg writer remains stopped until the writer step."

LAB_HOME="${LAB_HOME}" "${START_LAKEHOUSE}"

echo "==> Verify Lakehouse service readiness"
wait_for_url "MinIO" "http://127.0.0.1:38900/minio/health/live"
wait_for_url "Iceberg REST Catalog" "http://127.0.0.1:38181/v1/config"
wait_for_url "Trino" "http://127.0.0.1:38080/v1/info"

echo "==> Lakehouse containers"
docker ps \
  --filter name=demo_minio \
  --filter name=demo_iceberg_catalog \
  --filter name=demo_trino \
  --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

if docker ps --format '{{.Names}}' | grep -qx 'demo_kafka_iceberg_writer'; then
  echo "WARN: demo_kafka_iceberg_writer is already running."
  echo "WARN: It may consume Kafka records before the writer step."
else
  echo "OK: demo_kafka_iceberg_writer is not running yet."
fi

echo "OK: Chapter 9 Lakehouse initialization completed."
