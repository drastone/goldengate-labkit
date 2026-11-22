#!/usr/bin/env bash
set -eu

# Start the lightweight Lakehouse/Iceberg foundation only for the Lakehouse
# labs. MinIO and the Iceberg REST Catalog are required. Trino and active Kafka
# consumers remain opt-in so they do not consume memory or replay events early.

LAB_HOME="${LAB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
MINIO_SERVICE="${MINIO_SERVICE:-demo_minio}"
ICEBERG_CATALOG_SERVICE="${ICEBERG_CATALOG_SERVICE:-demo_iceberg_catalog}"
TRINO_SERVICE="${TRINO_SERVICE:-demo_trino}"
MINIO_CONTAINER="${MINIO_CONTAINER:-demo_minio}"
ICEBERG_CATALOG_CONTAINER="${ICEBERG_CATALOG_CONTAINER:-demo_iceberg_catalog}"
TRINO_CONTAINER="${TRINO_CONTAINER:-demo_trino}"
MINIO_API_PORT="${MINIO_API_PORT:-38900}"
ICEBERG_CATALOG_PORT="${ICEBERG_CATALOG_PORT:-38181}"
TRINO_PORT="${TRINO_PORT:-38080}"
LAKEHOUSE_TRINO_AUTOSTART="${LAKEHOUSE_TRINO_AUTOSTART:-N}"
LAKEHOUSE_QUERY_API_AUTOSTART="${LAKEHOUSE_QUERY_API_AUTOSTART:-N}"
LAKEHOUSE_WRITER_AUTOSTART="${LAKEHOUSE_WRITER_AUTOSTART:-N}"
LAKEHOUSE_REPO_DIR="${LAKEHOUSE_REPO_DIR:-${LAB_HOME}/oracle}"
LAKEHOUSE_QUERY_API_DIR="${LAKEHOUSE_QUERY_API_DIR:-${LAKEHOUSE_REPO_DIR}/script/lakehouse/query-api}"
LAKEHOUSE_WRITER_DIR="${LAKEHOUSE_WRITER_DIR:-${LAKEHOUSE_REPO_DIR}/script/lakehouse/kafka-iceberg-writer}"

is_enabled() {
  case "${1:-}" in
    1|Y|y|YES|yes|TRUE|true|ON|on) return 0 ;;
    *) return 1 ;;
  esac
}

check_get_url() {
  local url="$1"
  if curl --max-time 10 -fsS "${url}" >/dev/null; then
    echo "OK: ${url}"
  else
    echo "WARN: check failed: ${url}"
  fi
}

echo "Start optional Lakehouse/Iceberg lab containers"
(
  cd "${LAB_HOME}" &&
  docker compose up -d "${MINIO_SERVICE}" "${ICEBERG_CATALOG_SERVICE}"
)

if is_enabled "${LAKEHOUSE_TRINO_AUTOSTART}"; then
  echo "==> Optional Trino: docker compose up"
  (
    cd "${LAB_HOME}" &&
    docker compose up -d "${TRINO_SERVICE}"
  )
else
  echo "INFO: LAKEHOUSE_TRINO_AUTOSTART=${LAKEHOUSE_TRINO_AUTOSTART}; skip optional Trino"
fi

if is_enabled "${LAKEHOUSE_QUERY_API_AUTOSTART}"; then
  if [ -f "${LAKEHOUSE_QUERY_API_DIR}/docker-compose.query-api.yml" ]; then
    echo "==> Lakehouse Query API: docker compose up"
    (
      cd "${LAKEHOUSE_QUERY_API_DIR}" &&
      docker compose -f docker-compose.query-api.yml up -d --build
    )
  else
    echo "WARN: Query API compose file not found: ${LAKEHOUSE_QUERY_API_DIR}/docker-compose.query-api.yml"
  fi
else
  echo "INFO: LAKEHOUSE_QUERY_API_AUTOSTART=${LAKEHOUSE_QUERY_API_AUTOSTART}; skip Lakehouse Query API"
fi

if is_enabled "${LAKEHOUSE_WRITER_AUTOSTART}"; then
  if [ -f "${LAKEHOUSE_WRITER_DIR}/docker-compose.kafka-iceberg-writer.yml" ] &&
     [ -f "${LAKEHOUSE_WRITER_DIR}/.env" ]; then
    echo "==> Kafka -> Iceberg writer: docker compose up"
    (
      cd "${LAKEHOUSE_WRITER_DIR}" &&
      docker compose --env-file .env -f docker-compose.kafka-iceberg-writer.yml up -d --build
    )
  else
    echo "WARN: Kafka -> Iceberg writer compose file or .env not found; skip writer"
  fi
else
  echo "INFO: LAKEHOUSE_WRITER_AUTOSTART=${LAKEHOUSE_WRITER_AUTOSTART}; skip Kafka -> Iceberg writer"
fi

sleep 5
check_get_url "http://127.0.0.1:${MINIO_API_PORT}/minio/health/live"
check_get_url "http://127.0.0.1:${ICEBERG_CATALOG_PORT}/v1/config"
if is_enabled "${LAKEHOUSE_TRINO_AUTOSTART}"; then
  check_get_url "http://127.0.0.1:${TRINO_PORT}/v1/info"
fi

docker ps --filter "name=${MINIO_CONTAINER}" --filter "name=${ICEBERG_CATALOG_CONTAINER}" \
  --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
