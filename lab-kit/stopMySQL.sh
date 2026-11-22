#!/usr/bin/env bash
set -eu

# Stop the optional MySQL -> HeatWave-compatible sandbox after the MySQL labs.

MYSQL_SOURCE_CONTAINER="${MYSQL_SOURCE_CONTAINER:-demo_mysql}"
MYSQL_HEATWAVE_CONTAINER="${MYSQL_HEATWAVE_CONTAINER:-demo_myheat}"

echo "Stop optional MySQL/HeatWave lab containers"
docker stop "${MYSQL_SOURCE_CONTAINER}" "${MYSQL_HEATWAVE_CONTAINER}" 2>/dev/null || true

docker ps --filter "name=${MYSQL_SOURCE_CONTAINER}" --filter "name=${MYSQL_HEATWAVE_CONTAINER}" \
  --format 'table {{.Names}}\t{{.Status}}'

