#!/bin/bash
set -euo pipefail

CONTAINER="${CONTAINER:-demo_otrg_23ai}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SQL_FILE="${SCRIPT_DIR}/show_fabric_metadata.sql"

printf "Show Chapter 20 fabric metadata\n"
printf "Host: "; uname -n
printf "\n"

docker cp "${SQL_FILE}" "${CONTAINER}:/tmp/show_fabric_metadata.sql"
docker exec -i "${CONTAINER}" bash -lc \
  "sqlplus / as sysdba @/tmp/show_fabric_metadata.sql"
