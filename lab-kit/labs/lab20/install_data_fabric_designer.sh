#!/bin/bash
set -euo pipefail

CONTAINER="${CONTAINER:-demo_otrg_23ai}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SQL_FILE="${SCRIPT_DIR}/install_data_fabric_designer.sql"

printf "Install Chapter 20 Data Fabric Designer\n"
printf "Host: "; uname -n
printf "Container: %s\n" "${CONTAINER}"
printf "SQL file : %s\n" "${SQL_FILE}"
printf "\n"

if [ ! -f "${SQL_FILE}" ]; then
  printf "ERROR: SQL file not found: %s\n" "${SQL_FILE}" >&2
  exit 1
fi

docker cp "${SQL_FILE}" "${CONTAINER}:/tmp/install_data_fabric_designer.sql"
docker exec -i "${CONTAINER}" bash -lc \
  "sqlplus / as sysdba @/tmp/install_data_fabric_designer.sql"

printf "\nData Fabric Designer URL:\n"
printf "  http://localhost:36080/ords/r/ogg/goldengate-console/data-fabric-designer\n"
