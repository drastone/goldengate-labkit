#!/bin/bash
set -euo pipefail

# Usage:
#   sh apply_fabric_change_request.sh [REQUEST_ID]
#
# The script applies a PLANNED Data Fabric change request created by the
# Set Table Wizard. If REQUEST_ID is omitted, the latest PLANNED request is
# used. The current implementation supports the lab20 EXTRACT TABLE flow:
# it backs up the GoldenGate PRM file, adds or removes a TABLE line, restarts
# only that Extract, marks the request APPLIED, and refreshes Fabric metadata.
#
# This is intentionally separate from the APEX preview step so that readers can
# see the control-plane approval boundary before runtime changes are made.

OGGHUB_CONTAINER="${OGGHUB_CONTAINER:-demo_ogg_23ai}"
TARGET_CONTAINER="${TARGET_CONTAINER:-demo_otrg_23ai}"
REQUEST_ID="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

sql_target() {
  docker exec -i "${TARGET_CONTAINER}" bash -lc "sqlplus -s / as sysdba"
}

run_admin() {
  local cmd="$1"
  docker exec -i -u ogg "${OGGHUB_CONTAINER}" python3 - "${cmd}" <<'PY'
import sys
import urllib.parse
import urllib.request

cmd = sys.argv[1]
url = "http://localhost:8765/api/adminclient?cmd=" + urllib.parse.quote(cmd)
print("OGG> " + cmd)
print(urllib.request.urlopen(url, timeout=60).read().decode())
PY
}

printf "Apply Chapter 20 Data Fabric change request\n"
printf "Host      : "; uname -n
printf "OGGHUB    : %s\n" "${OGGHUB_CONTAINER}"
printf "Target DB : %s\n" "${TARGET_CONTAINER}"

if [ -z "${REQUEST_ID}" ]; then
  REQUEST_ID="$(
    sql_target <<'SQL' | awk 'NF && $1 ~ /^[0-9]+$/ {print $1}' | tail -1
set heading off feedback off pages 0 verify off echo off
alter session set container=ORCLPDB1;
select max(request_id)
  from ggadmin.fabric_change_request
 where request_status = 'PLANNED';
SQL
  )"
fi

if [ -z "${REQUEST_ID}" ]; then
  printf "ERROR: no PLANNED change request found.\n" >&2
  exit 1
fi

printf "Request  : %s\n\n" "${REQUEST_ID}"

REQ_DATA="$(
  sql_target <<SQL | awk 'BEGIN{FS="|"} NF>=5 {print}'
set heading off feedback off pages 0 verify off echo off lines 4000
alter session set container=ORCLPDB1;
select request_id || '|' || process_type || '|' || process_name || '|' || source_table || '|' || replace(change_sql, chr(10), ' ')
  from ggadmin.fabric_change_request
 where request_id = ${REQUEST_ID}
   and request_status = 'PLANNED';
SQL
)"

if [ -z "${REQ_DATA}" ]; then
  printf "ERROR: request %s is not PLANNED or does not exist.\n" "${REQUEST_ID}" >&2
  exit 1
fi

IFS='|' read -r REQ_ID PROCESS_TYPE PROCESS_NAME SOURCE_TABLE CHANGE_SQL <<EOF
${REQ_DATA}
EOF

PROCESS_REF="$(printf "%s" "${PROCESS_NAME}" | awk '{print toupper($NF)}')"
SOURCE_TABLE="$(printf "%s" "${SOURCE_TABLE}" | tr '[:lower:]' '[:upper:]')"
PROCESS_TYPE="$(printf "%s" "${PROCESS_TYPE}" | tr '[:lower:]' '[:upper:]')"
CHANGE_SQL_UPPER="$(printf "%s" "${CHANGE_SQL}" | tr '[:lower:]' '[:upper:]')"
CHANGE_ACTION="ADD"
case "${CHANGE_SQL_UPPER}" in
  REMOVE\ TABLE*|REMOVE\ MAP*) CHANGE_ACTION="REMOVE" ;;
esac

if [ "${PROCESS_TYPE}" != "EXTRACT" ]; then
  printf "ERROR: this script currently applies EXTRACT TABLE requests only. Found: %s\n" "${PROCESS_TYPE}" >&2
  exit 1
fi

case "${PROCESS_REF}" in
  FC01) PRM_FILE="/u02/Deployment/etc/conf/ogg/fc01.prm" ;;
  FC02) PRM_FILE="/u02/Deployment/etc/conf/ogg/fc02.prm" ;;
  C01)  PRM_FILE="/u02/Deployment/etc/conf/ogg/c01.prm" ;;
  *)
    printf "ERROR: unsupported Extract process: %s\n" "${PROCESS_REF}" >&2
    exit 1
    ;;
esac

printf "Process   : %s\n" "${PROCESS_REF}"
printf "Table     : %s\n" "${SOURCE_TABLE}"
printf "Action    : %s\n" "${CHANGE_ACTION}"
printf "PRM file  : %s\n\n" "${PRM_FILE}"

docker exec -i -u root "${OGGHUB_CONTAINER}" bash -lc "
set -e
prm='${PRM_FILE}'
table_name='${SOURCE_TABLE}'
action='${CHANGE_ACTION}'
bak=\"\${prm}.bak_\$(date +%Y%m%d_%H%M%S)\"
cp -p \"\${prm}\" \"\${bak}\"
if [ \"\${action}\" = \"REMOVE\" ]; then
  if grep -qi \"^TABLE[[:space:]]\\+\${table_name};\" \"\${prm}\"; then
    tmp=\"\${prm}.tmp_\$\$\"
    grep -vi \"^TABLE[[:space:]]\\+\${table_name};\" \"\${prm}\" > \"\${tmp}\"
    cat \"\${tmp}\" > \"\${prm}\"
    rm -f \"\${tmp}\"
    chown ogg:ogg \"\${prm}\"
    echo \"TABLE removed from \${prm}. backup=\${bak}\"
  else
    echo \"TABLE was not present in \${prm}. backup=\${bak}\"
  fi
else
  if grep -qi \"^TABLE[[:space:]]\\+\${table_name};\" \"\${prm}\"; then
    echo \"TABLE already exists in \${prm}. backup=\${bak}\"
  else
    printf 'TABLE %s;\\n' \"\${table_name}\" >> \"\${prm}\"
    chown ogg:ogg \"\${prm}\"
    echo \"TABLE added to \${prm}. backup=\${bak}\"
  fi
fi
sed -n '1,120p' \"\${prm}\"
"

run_admin "stop ${PROCESS_REF}!"
run_admin "start ${PROCESS_REF}"
sleep 4
run_admin "info extract ${PROCESS_REF}"

sql_target <<SQL
alter session set container=ORCLPDB1;
update ggadmin.fabric_change_request
   set request_status = 'APPLIED'
 where request_id = ${REQUEST_ID};
commit;
SQL

if [ -x "${SCRIPT_DIR}/refresh_fabric_metadata.sh" ]; then
  "${SCRIPT_DIR}/refresh_fabric_metadata.sh"
else
  sh "${SCRIPT_DIR}/refresh_fabric_metadata.sh"
fi

printf "\nChange request %s applied.\n" "${REQUEST_ID}"
