#!/usr/bin/env bash
set -eu

# Stop the optional Lakehouse/Iceberg stack after the Lakehouse labs.

LAB_HOME="${LAB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
MINIO_CONTAINER="${MINIO_CONTAINER:-demo_minio}"
ICEBERG_CATALOG_CONTAINER="${ICEBERG_CATALOG_CONTAINER:-demo_iceberg_catalog}"
TRINO_CONTAINER="${TRINO_CONTAINER:-demo_trino}"
LAKEHOUSE_REPO_DIR="${LAKEHOUSE_REPO_DIR:-${LAB_HOME}/oracle}"
LAKEHOUSE_QUERY_API_DIR="${LAKEHOUSE_QUERY_API_DIR:-${LAKEHOUSE_REPO_DIR}/script/lakehouse/query-api}"
LAKEHOUSE_WRITER_DIR="${LAKEHOUSE_WRITER_DIR:-${LAKEHOUSE_REPO_DIR}/script/lakehouse/kafka-iceberg-writer}"
STOP_LAKEHOUSE_APPS="${STOP_LAKEHOUSE_APPS:-Y}"

is_enabled() {
  case "${1:-}" in
    1|Y|y|YES|yes|TRUE|true|ON|on) return 0 ;;
    *) return 1 ;;
  esac
}

echo "Stop optional Lakehouse/Iceberg lab containers"

if is_enabled "${STOP_LAKEHOUSE_APPS}"; then
  if [ -f "${LAKEHOUSE_WRITER_DIR}/docker-compose.kafka-iceberg-writer.yml" ]; then
    (
      cd "${LAKEHOUSE_WRITER_DIR}" &&
      docker compose -f docker-compose.kafka-iceberg-writer.yml down
    ) || true
  fi
  if [ -f "${LAKEHOUSE_QUERY_API_DIR}/docker-compose.query-api.yml" ]; then
    (
      cd "${LAKEHOUSE_QUERY_API_DIR}" &&
      docker compose -f docker-compose.query-api.yml down
    ) || true
  fi
fi

docker stop "${TRINO_CONTAINER}" "${ICEBERG_CATALOG_CONTAINER}" "${MINIO_CONTAINER}" 2>/dev/null || true

docker ps --filter "name=${MINIO_CONTAINER}" --filter "name=${ICEBERG_CATALOG_CONTAINER}" --filter "name=${TRINO_CONTAINER}" \
  --format 'table {{.Names}}\t{{.Status}}'
