#!/usr/bin/env bash
set -eu

# Start the optional MySQL -> HeatWave-compatible sandbox only for the MySQL
# labs. Keep this separate from startDocker.sh so the base GoldenGate/OSA labs
# stay lightweight.

LAB_HOME="${LAB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
MYSQL_SOURCE_CONTAINER="${MYSQL_SOURCE_CONTAINER:-demo_mysql}"
MYSQL_HEATWAVE_CONTAINER="${MYSQL_HEATWAVE_CONTAINER:-demo_myheat}"
MYSQL_SOURCE_SERVICE="${MYSQL_SOURCE_SERVICE:-mysql}"
MYSQL_HEATWAVE_SERVICE="${MYSQL_HEATWAVE_SERVICE:-myheat}"

has_container() {
  docker inspect "$1" >/dev/null 2>&1
}

start_existing_container() {
  local container="$1"
  if has_container "${container}"; then
    echo "==> docker start ${container}"
    docker start "${container}" >/dev/null
    return 0
  fi
  return 1
}

echo "Start optional MySQL/HeatWave lab containers"

if ! start_existing_container "${MYSQL_SOURCE_CONTAINER}" ||
   ! start_existing_container "${MYSQL_HEATWAVE_CONTAINER}"; then
  echo "==> docker compose up ${MYSQL_SOURCE_SERVICE} ${MYSQL_HEATWAVE_SERVICE}"
  (
    cd "${LAB_HOME}" &&
    docker compose up -d "${MYSQL_SOURCE_SERVICE}" "${MYSQL_HEATWAVE_SERVICE}"
  )
fi

docker ps --filter "name=${MYSQL_SOURCE_CONTAINER}" --filter "name=${MYSQL_HEATWAVE_CONTAINER}" \
  --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

