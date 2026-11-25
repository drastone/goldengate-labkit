#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.oggmysql.yml"
CONTAINER=demo_oggmysql_23ai

bash "${SCRIPT_DIR}/ensure_oggmysql_image.sh"

mkdir -p "${SCRIPT_DIR}/data"
docker compose -f "${COMPOSE_FILE}" up -d

echo "Wait for GoldenGate for MySQL."
for attempt in $(seq 1 60); do
  status="$(docker inspect -f '{{.State.Health.Status}}' "${CONTAINER}" 2>/dev/null || true)"
  if [ "${status}" = healthy ]; then
    echo "OK: ${CONTAINER} is healthy."
    echo "GoldenGate for MySQL URL: https://localhost:38443/"
    exit 0
  fi
  if [ "${status}" = unhealthy ]; then
    docker logs --tail 80 "${CONTAINER}" || true
    echo "ERROR: ${CONTAINER} became unhealthy." >&2
    exit 1
  fi
  sleep 5
done

docker logs --tail 80 "${CONTAINER}" || true
echo "ERROR: ${CONTAINER} did not become healthy within 5 minutes." >&2
exit 1
