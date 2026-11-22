#!/bin/bash

if [ -z "${BASH_VERSION:-}" ] || shopt -qo posix 2>/dev/null; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  fi
  echo "ERROR: lab20_init.sh requires bash." >&2
  exit 1
fi

set -euo pipefail

LAB20_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_HOME="${LAB_HOME:-$(cd "${LAB20_DIR}/../.." && pwd)}"
LAB_LOGGING="${LAB_HOME}/troubleshooting/scripts/lab_init_logging.sh"
OGGHUB_CONTAINER="${OGGHUB_CONTAINER:-demo_ogg_23ai}"
TARGET_DB_CONTAINER="${TARGET_DB_CONTAINER:-demo_otrg_23ai}"
TARGET_PDB="${TARGET_PDB:-ORCLPDB1}"
TARGET_ORDS_PORT="${TARGET_ORDS_PORT:-36080}"
APEX_WORKSPACE="${APEX_WORKSPACE:-OGG}"
DOMAIN="${DOMAIN:-OracleGoldenGate}"
NORMAL_TRAIL="${NORMAL_TRAIL:-k1}"
HEAVY_TRAIL="${HEAVY_TRAIL:-k2}"
CHECKPOINT_TABLE="${CHECKPOINT_TABLE:-OGG.GGSCKPT}"
RESET_SETTLE_SECONDS="${RESET_SETTLE_SECONDS:-5}"

if [ ! -f "${LAB_LOGGING}" ]; then
  echo "ERROR: shared Lab logging helper not found: ${LAB_LOGGING}" >&2
  exit 1
fi
source "${LAB_LOGGING}"
lab_init_log_begin lab20 lab20-init
RUNTIME_START="${LAB20_DIR}/start_lab20_fabric_console.sh"

if [ ! -x "${RUNTIME_START}" ]; then
  printf "ERROR: Chapter 20 runtime helper is missing or not executable: %s\n" "${RUNTIME_START}" >&2
  exit 1
fi

verify_manual_app101_import() {
  local ready_count=""
  local response_file="/tmp/lab20-app101-response.$$"
  local http_code=""
  local app_url="http://127.0.0.1:${TARGET_ORDS_PORT}/ords/r/ogg/goldengate-console"

  ready_count="$(docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba <<'SQL'
set pages 0 feedback off heading off verify off echo off trimspool on
whenever sqlerror exit sql.sqlcode
alter session set container=${TARGET_PDB};
select 'LAB20_APP101=' || count(*)
from apex_applications a
where a.workspace = upper('${APEX_WORKSPACE}')
  and upper(a.alias) = 'GOLDENGATE-CONSOLE'
  and exists (
    select 1
    from apex_application_pages p
    where p.application_id = a.application_id
      and p.page_id = 200
  );
exit
SQL" | sed -n 's/^[[:space:]]*LAB20_APP101=//p' | tail -1)"

  if [ "${ready_count:-0}" -ne 1 ]; then
    printf "ERROR: Chapter 13 manual App 101 import is incomplete.\n" >&2
    printf "ERROR: import App 101 and install Supporting Objects through APEX App Builder as shown in Chapter 13, then rerun lab20_init.sh.\n" >&2
    return 1
  fi
  printf "OK: manually imported App 101 GOLDENGATE-CONSOLE and Page 200 are installed.\n"

  http_code="$(curl -sS -o "${response_file}" -w '%{http_code}' "${app_url}" || true)"
  if grep -Eiq "Application not found|Sorry, this page isn't available" "${response_file}" 2>/dev/null; then
    rm -f "${response_file}"
    printf "ERROR: ORDS reports that the manually imported App 101 is unavailable: %s\n" "${app_url}" >&2
    return 1
  fi
  rm -f "${response_file}"
  case "${http_code}" in
    2??|3??) printf "OK: App 101 endpoint is available (HTTP %s): %s\n" "${http_code}" "${app_url}" ;;
    *) printf "ERROR: App 101 endpoint returned HTTP %s: %s\n" "${http_code:-000}" "${app_url}" >&2; return 1 ;;
  esac
}

printf "Chapter 20 uses only the minimum Data Fabric Console runtime.\n"
printf "Required containers:\n"
printf "  - demo_osrc_23ai  : Source Oracle Database\n"
printf "  - demo_otrg_23ai  : Target Oracle Database and APEX/ORDS\n"
printf "  - demo_ogg_23ai   : GoldenGate Hub and Fabric lanes\n"
printf "  - demo_oggbd_23ai : GoldenGate Big Data deployment metadata\n"
printf "Other Kafka/OSA and Lakehouse containers are stopped to release notebook resources.\n\n"
printf "Legacy GoldenGate processes C01 and D01 belong to the earlier core replication path.\n"
printf "Chapter 20 does not use that path, so this script stops C01 and D01 cleanly.\n"
printf "Chapter 20 uses FC01/FC02 and FD01/FD02/FD03 for the Data Fabric exercises.\n\n"

printf "==> Prepare the Chapter 20 minimum runtime.\n"
bash "${RUNTIME_START}"
printf "\n"

printf "==> Verify the manual Chapter 13 App 101 import.\n"
verify_manual_app101_import
printf "\n"

printf "Reset Chapter 20 Data Fabric GoldenGate lanes\n"
printf "Host        : "; uname -n
printf "OGGHUB      : %s\n" "${OGGHUB_CONTAINER}"
printf "Normal trail: %s\n" "${NORMAL_TRAIL}"
printf "Heavy trail : %s\n" "${HEAVY_TRAIL}"
printf "\n"

run_admin() {
  local container="$1"
  shift

  for cmd in "$@"; do
    docker exec -i -u ogg "${container}" python3 - "${cmd}" <<'PY'
import sys
import json
import urllib.parse
import urllib.request

cmd = sys.argv[1]
url = "http://localhost:8765/api/adminclient?cmd=" + urllib.parse.quote(cmd)
print("OGG> " + cmd)
payload = urllib.request.urlopen(url, timeout=60).read().decode()
try:
    data = json.loads(payload)
    text = data.get("output") or data.get("response", {}).get("reply") or payload
except json.JSONDecodeError:
    text = payload

skip_patterns = (
    "OGG-06594",
    "OGG-08272",
)
lines = [line for line in text.splitlines() if not any(p in line for p in skip_patterns)]
rendered = "\n".join(lines).strip()
print(rendered)
if any("ERROR" in line.upper() for line in lines):
    sys.exit(1)
PY
  done
}

run_admin_ignore() {
  local container="$1"
  shift

  if ! run_admin "${container}" "$@"; then
    printf "WARN: ignored Admin Client failure: %s\n" "$*" >&2
  fi
}

admin_output() {
  local container="$1"
  local cmd="$2"
  docker exec -i -u ogg "${container}" python3 - "${cmd}" <<'PY'
import sys
import json
import urllib.parse
import urllib.request

cmd = sys.argv[1]
url = "http://localhost:8765/api/adminclient?cmd=" + urllib.parse.quote(cmd)
try:
    payload = urllib.request.urlopen(url, timeout=60).read().decode()
    try:
        data = json.loads(payload)
        print(data.get("output") or data.get("response", {}).get("reply") or payload)
    except json.JSONDecodeError:
        print(payload)
except Exception as exc:
    print(str(exc))
    sys.exit(1)
PY
}

wait_group_running() {
  local process_type="$1"
  local process_name="$2"
  local attempts="${3:-12}"
  local delay_seconds="${4:-2}"
  local allow_transient_abended="${5:-N}"
  local status_text=""
  local i=1

  while [ "${i}" -le "${attempts}" ]; do
    status_text="$(admin_output "${OGGHUB_CONTAINER}" "info ${process_type} ${process_name}" 2>&1 || true)"
    if printf '%s\n' "${status_text}" | grep -Eq 'Status[[:space:]]+RUNNING'; then
      printf "OK: %s %s is RUNNING.\n" "${process_type}" "${process_name}"
      return 0
    fi
    if printf '%s\n' "${status_text}" | grep -Eiq 'does not exist|not found|ERROR'; then
      printf "ERROR: %s %s did not reach RUNNING state.\n%s\n" \
        "${process_type}" "${process_name}" "${status_text}" >&2
      return 1
    fi
    if printf '%s\n' "${status_text}" | grep -Eiq 'ABENDED' && [ "${allow_transient_abended}" != "Y" ]; then
      printf "ERROR: %s %s did not reach RUNNING state.\n%s\n" \
        "${process_type}" "${process_name}" "${status_text}" >&2
      return 1
    fi
    sleep "${delay_seconds}"
    i=$((i + 1))
  done

  printf "ERROR: %s %s did not reach RUNNING state within %s seconds.\n%s\n" \
    "${process_type}" "${process_name}" "$((attempts * delay_seconds))" "${status_text}" >&2
  return 1
}

wait_group_stopped() {
  local process_type="$1"
  local process_name="$2"
  local attempts="${3:-12}"
  local delay_seconds="${4:-2}"
  local status_text=""
  local i=1

  while [ "${i}" -le "${attempts}" ]; do
    status_text="$(admin_output "${OGGHUB_CONTAINER}" "info ${process_type} ${process_name}" 2>&1 || true)"
    if printf '%s\n' "${status_text}" | grep -Eq 'Status[[:space:]]+STOPPED'; then
      printf "OK: %s %s is STOPPED.\n" "${process_type}" "${process_name}"
      return 0
    fi
    if printf '%s\n' "${status_text}" | grep -Eiq 'does not exist|not found|OGG-12029'; then
      printf "SKIP: %s %s is not registered.\n" "${process_type}" "${process_name}"
      return 0
    fi
    if printf '%s\n' "${status_text}" | grep -Eiq 'Status[[:space:]]+ABENDED'; then
      printf "ERROR: %s %s remains ABENDED instead of STOPPED.\n%s\n" \
        "${process_type}" "${process_name}" "${status_text}" >&2
      return 1
    fi
    sleep "${delay_seconds}"
    i=$((i + 1))
  done

  printf "ERROR: %s %s did not reach STOPPED state within %s seconds.\n%s\n" \
    "${process_type}" "${process_name}" "$((attempts * delay_seconds))" "${status_text}" >&2
  return 1
}

stop_legacy_group() {
  local process_type="$1"
  local process_name="$2"
  local status_text=""

  status_text="$(admin_output "${OGGHUB_CONTAINER}" "info ${process_type} ${process_name}" 2>&1 || true)"
  if printf '%s\n' "${status_text}" | grep -Eiq 'does not exist|not found|OGG-12029'; then
    printf "SKIP: legacy %s %s is not registered.\n" "${process_type}" "${process_name}"
    return 0
  fi
  if printf '%s\n' "${status_text}" | grep -Eq 'Status[[:space:]]+STOPPED'; then
    printf "OK: legacy %s %s is already STOPPED.\n" "${process_type}" "${process_name}"
    return 0
  fi
  if printf '%s\n' "${status_text}" | grep -Eq 'Status[[:space:]]+ABENDED'; then
    printf "INFO: restart legacy %s %s so it can be stopped cleanly.\n" "${process_type}" "${process_name}"
    run_admin "${OGGHUB_CONTAINER}" "start ${process_name}"
    wait_group_running "${process_type}" "${process_name}" 24 2 Y
  fi

  printf "Stop legacy %s %s for the Chapter 20 minimum runtime.\n" "${process_type}" "${process_name}"
  run_admin "${OGGHUB_CONTAINER}" "stop ${process_name}"
  wait_group_stopped "${process_type}" "${process_name}"
}

wait_not_running() {
  local process_type="$1"
  local process_name="$2"
  local attempts="${3:-12}"
  local delay_seconds="${4:-5}"
  local status_text=""
  local i=1

  while [ "${i}" -le "${attempts}" ]; do
    status_text="$(admin_output "${OGGHUB_CONTAINER}" "info ${process_type} ${process_name}" 2>&1 || true)"
    if printf "%s\n" "${status_text}" | grep -Eiq "No .*${process_name}|not found|does not exist|Could not find|ERROR|OGG-0"; then
      if ! printf "%s\n" "${status_text}" | grep -Eiq "Status RUNNING|RUNNING"; then
        printf "OK: %s %s is not running or no longer registered.\n" "${process_type}" "${process_name}"
        return 0
      fi
    fi
    if printf "%s\n" "${status_text}" | grep -Eiq "Status (STOPPED|ABENDED|KILLED)|is down|STOPPED|ABENDED"; then
      printf "OK: %s %s is no longer running.\n" "${process_type}" "${process_name}"
      return 0
    fi
    if ! printf "%s\n" "${status_text}" | grep -Eiq "Status RUNNING|RUNNING"; then
      printf "OK: %s %s is not running.\n" "${process_type}" "${process_name}"
      return 0
    fi

    printf "... waiting for %s %s to leave RUNNING state (%s/%s).\n" "${process_type}" "${process_name}" "${i}" "${attempts}"
    sleep "${delay_seconds}"
    i=$((i + 1))
  done

  printf "ERROR: %s %s is still RUNNING after %s seconds.\n" "${process_type}" "${process_name}" "$((attempts * delay_seconds))" >&2
  printf "%s\n" "${status_text}" >&2
  return 1
}

verify_groups_absent() {
  local status_text=""
  local group_name=""

  if ! status_text="$(admin_output "${OGGHUB_CONTAINER}" "info all")"; then
    printf "ERROR: could not verify removed GoldenGate process definitions.\n" >&2
    return 1
  fi
  for group_name in "$@"; do
    if printf '%s\n' "${status_text}" | grep -Eq "(EXTRACT|REPLICAT)[[:space:]]+[[:upper:]]+[[:space:]]+${group_name}([[:space:]]|$)"; then
      printf "ERROR: %s remains registered; refusing to remove its trail.\n" "${group_name}" >&2
      return 1
    fi
    printf "OK: %s is no longer registered.\n" "${group_name}"
  done
}

run_admin_batch() {
  local container="$1"
  docker exec -i -u ogg "${container}" bash -lc "cd /u01/ogg && ./bin/adminclient" 2>&1 \
    | sed -E \
      -e '/OGG-01525/d' \
      -e '/^Oracle GoldenGate Administration Client/d' \
      -e '/^Version /d' \
      -e '/^Copyright /d' \
      -e '/^Linux, /d' \
      -e '/^Operating system character/d' \
      -e '/^$/d' \
      -e '/^OGG .* [0-9]+> exit/d' \
      -e 's/password [^ ]+/password ********/g' \
      -e '/^OGG /!{/Successfully logged into database/!{/INFO    OGG-/!d;};}'
}

clear_replicat_checkpoints() {
  local groups_csv="$1"

  if [ "$(docker inspect -f '{{.State.Running}}' "${TARGET_DB_CONTAINER}" 2>/dev/null || true)" != "true" ]; then
    printf "ERROR: Target DB container must be running to clear Replicat checkpoints: %s\n" "${TARGET_DB_CONTAINER}" >&2
    return 1
  fi

  docker exec -i -u oracle "${TARGET_DB_CONTAINER}" bash -lc 'sqlplus -s / as sysdba' <<SQL
set serveroutput on feedback off verify off
whenever sqlerror exit sql.sqlcode
alter session set container=ORCLPDB1;
declare
  l_exists number;
  l_rows   number := 0;
begin
  select count(*) into l_exists from dba_tables
   where owner = 'OGG' and table_name = 'GGSCKPT';
  if l_exists = 1 then
    execute immediate q'[delete from ogg.ggsckpt where upper(group_name) in (${groups_csv})]';
    l_rows := sql%rowcount;
    commit;
  end if;
  dbms_output.put_line('OK: cleared ' || l_rows || ' stale Replicat checkpoint row(s).');
end;
/
exit
SQL
}

printf "Stop the earlier core replication processes that Chapter 20 does not use.\n"
stop_legacy_group extract C01
stop_legacy_group replicat D01
printf "\n"

printf "Reset existing Chapter 20 Replicat lanes if they exist.\n"
set +e
run_admin_batch "${OGGHUB_CONTAINER}" <<OGG
connect http://localhost:9011 deployment OGGHUB as oggadmin password WElcome1234## !
dblogin useridalias trg_ogg domain ${DOMAIN}
kill replicat FD01!
kill replicat FD02!
kill replicat FD03!
exit
OGG
set -e
wait_not_running replicat FD01
wait_not_running replicat FD02
wait_not_running replicat FD03
set +e
run_admin_batch "${OGGHUB_CONTAINER}" <<OGG
connect http://localhost:9011 deployment OGGHUB as oggadmin password WElcome1234## !
dblogin useridalias trg_ogg domain ${DOMAIN}
delete replicat FD01!
delete replicat FD02!
delete replicat FD03!
exit
OGG
set -e
verify_groups_absent FD01 FD02 FD03
clear_replicat_checkpoints "'FD01','FD02','FD03'"

printf "\nReset existing Chapter 20 integrated Extract lanes if they exist.\n"
set +e
run_admin_batch "${OGGHUB_CONTAINER}" <<OGG
connect http://localhost:9011 deployment OGGHUB as oggadmin password WElcome1234## !
dblogin useridalias src_ogg domain ${DOMAIN}
kill extract FC01!
kill extract FC02!
exit
OGG
set -e
wait_not_running extract FC01
wait_not_running extract FC02
set +e
run_admin_batch "${OGGHUB_CONTAINER}" <<OGG
connect http://localhost:9011 deployment OGGHUB as oggadmin password WElcome1234## !
dblogin useridalias src_ogg domain ${DOMAIN}
unregister extract FC01 database
delete extract FC01!
unregister extract FC02 database
delete extract FC02!
exit
OGG
set -e
verify_groups_absent FC01 FC02

printf "\nWait for Chapter 20 process handles to settle before removing trails.\n"
sleep "${RESET_SETTLE_SECONDS}"
docker exec -i -u root "${OGGHUB_CONTAINER}" bash -lc "
set -euo pipefail
cd /u02/Deployment/var/lib
shopt -s nullglob
files=(data/${NORMAL_TRAIL}* data/${HEAVY_TRAIL}*)
if [ \${#files[@]} -gt 0 ]; then
  rm -f \"\${files[@]}\"
  echo 'OK: removed stale Chapter 20 trails ${NORMAL_TRAIL}* and ${HEAVY_TRAIL}*.'
else
  echo 'SKIP: no stale Chapter 20 trail files were found.'
fi
"

printf "\nCreate Chapter 20 Data Fabric parameter files.\n"
docker exec -i -u root "${OGGHUB_CONTAINER}" bash -lc "cat > /u02/Deployment/etc/conf/ogg/fc01.prm <<'PRM'
EXTRACT FC01
USERIDALIAS src_ogg DOMAIN OracleGoldenGate
TRANLOGOPTIONS INTEGRATEDPARAMS (max_sga_size 256)
UPDATERECORDFORMAT COMPACT
DDL INCLUDE MAPPED
EXTTRAIL k1
-- Normal business tables are captured explicitly for table-level Fabric lineage.
TABLE SOE.ADDRESS;
TABLE SOE.ADDRESS_BAK_BEFORE_ENRICH;
TABLE SOE.ADDRESS_BAK_SEOUL_20261008_125131;
TABLE SOE.CALL_CENTER_LOG;
TABLE SOE.CANCELFP;
TABLE SOE.CFUND_DEPOSIT;
TABLE SOE.CFUND_RAT;
TABLE SOE.CFUND_RATIO;
TABLE SOE.CFUND_RAT_TMP;
TABLE SOE.CUST_DEP_DT;
TABLE SOE.CUST_GEN_AMT;
TABLE SOE.CUST_INFO;
TABLE SOE.CUST_PR;
TABLE SOE.EMPLOYEE;
TABLE SOE.FUNDM;
TABLE SOE.FUND_PRICE;
TABLE SOE.HEARTBP;
TABLE SOE.MSG;
TABLE SOE.OGG_SYNC_UNIT_TEST;
TABLE SOE.OPM;
TABLE SOE.OSA_CANCEL_PREDICTION;
TABLE SOE.OSA_CANCEL_PREDICTION_GEN;
TABLE SOE.PRODUCT;
TABLE SOE.RESERVES_AMT;
TABLE SOE.SUCCESS_CASE_KNOWLEDGE;
TABLE SOE.TMP_TRIGGER;
PRM
cat > /u02/Deployment/etc/conf/ogg/fc02.prm <<'PRM'
EXTRACT FC02
USERIDALIAS src_ogg DOMAIN OracleGoldenGate
TRANLOGOPTIONS INTEGRATEDPARAMS (max_sga_size 256)
UPDATERECORDFORMAT COMPACT
DDL INCLUDE MAPPED
EXTTRAIL k2
-- Chapter 20 heavy/aggregate exercise lane.
TABLE SOE.CFUND_DT;
TABLE SOE.OPSTATUS;
TABLE SOE.TOT_AMT;
TABLE SOE.CANCELAMT;
PRM
cat > /u02/Deployment/etc/conf/ogg/fd01.prm <<'PRM'
REPLICAT FD01
CACHEMGR CACHESIZE 128M
USERIDALIAS trg_ogg DOMAIN OracleGoldenGate
ASSUMETARGETDEFS
APPLYNOOPUPDATES
DISCARDFILE FD01_FABRIC.dsc, PURGE, MEGABYTES 100
REPORTCOUNT EVERY 1 MINUTES RATE
DDL INCLUDE MAPPED
DDLERROR 4080 IGNORE
DDLERROR 942 IGNORE
DDLERROR 4043 IGNORE
DDLERROR 1434 IGNORE
-- Normal business tables from k1.
MAP SOE.ADDRESS, TARGET SOE.ADDRESS;
MAP SOE.ADDRESS_BAK_BEFORE_ENRICH, TARGET SOE.ADDRESS_BAK_BEFORE_ENRICH;
MAP SOE.ADDRESS_BAK_SEOUL_20261008_125131, TARGET SOE.ADDRESS_BAK_SEOUL_20261008_125131;
MAP SOE.CALL_CENTER_LOG, TARGET SOE.CALL_CENTER_LOG;
MAP SOE.CANCELFP, TARGET SOE.CANCELFP;
MAP SOE.CFUND_DEPOSIT, TARGET SOE.CFUND_DEPOSIT;
MAP SOE.CFUND_RAT, TARGET SOE.CFUND_RAT;
MAP SOE.CFUND_RATIO, TARGET SOE.CFUND_RATIO;
MAP SOE.CFUND_RAT_TMP, TARGET SOE.CFUND_RAT_TMP;
MAP SOE.CUST_DEP_DT, TARGET SOE.CUST_DEP_DT;
MAP SOE.CUST_GEN_AMT, TARGET SOE.CUST_GEN_AMT;
MAP SOE.CUST_INFO, TARGET SOE.CUST_INFO;
MAP SOE.CUST_PR, TARGET SOE.CUST_PR;
MAP SOE.EMPLOYEE, TARGET SOE.EMPLOYEE;
MAP SOE.FUNDM, TARGET SOE.FUNDM;
MAP SOE.FUND_PRICE, TARGET SOE.FUND_PRICE;
MAP SOE.HEARTBP, TARGET SOE.HEARTBP;
MAP SOE.MSG, TARGET SOE.MSG;
MAP SOE.OGG_SYNC_UNIT_TEST, TARGET SOE.OGG_SYNC_UNIT_TEST;
MAP SOE.OPM, TARGET SOE.OPM;
MAP SOE.OSA_CANCEL_PREDICTION, TARGET SOE.OSA_CANCEL_PREDICTION;
MAP SOE.OSA_CANCEL_PREDICTION_GEN, TARGET SOE.OSA_CANCEL_PREDICTION_GEN;
MAP SOE.PRODUCT, TARGET SOE.PRODUCT;
MAP SOE.RESERVES_AMT, TARGET SOE.RESERVES_AMT;
MAP SOE.SUCCESS_CASE_KNOWLEDGE, TARGET SOE.SUCCESS_CASE_KNOWLEDGE;
MAP SOE.TMP_TRIGGER, TARGET SOE.TMP_TRIGGER;
PRM
cat > /u02/Deployment/etc/conf/ogg/fd02.prm <<'PRM'
REPLICAT FD02
CACHEMGR CACHESIZE 128M
USERIDALIAS trg_ogg DOMAIN OracleGoldenGate
ASSUMETARGETDEFS
APPLYNOOPUPDATES
DISCARDFILE FD02_FABRIC.dsc, PURGE, MEGABYTES 100
REPORTCOUNT EVERY 1 MINUTES RATE
DDL INCLUDE MAPPED
DDLERROR 4080 IGNORE
DDLERROR 942 IGNORE
DDLERROR 4043 IGNORE
DDLERROR 1434 IGNORE
-- Initial state for Chapter 20 Remove and Move exercises.
MAP SOE.CFUND_DT, TARGET SOE.CFUND_DT;
MAP SOE.TOT_AMT, TARGET SOE.TOT_AMT;
MAP SOE.OPM, TARGET SOE.OPM, COLMAP (USEDEFAULTS);
PRM
cat > /u02/Deployment/etc/conf/ogg/fd03.prm <<'PRM'
REPLICAT FD03
CACHEMGR CACHESIZE 128M
USERIDALIAS trg_ogg DOMAIN OracleGoldenGate
ASSUMETARGETDEFS
APPLYNOOPUPDATES
DISCARDFILE FD03_FABRIC.dsc, PURGE, MEGABYTES 100
REPORTCOUNT EVERY 1 MINUTES RATE
DDL INCLUDE MAPPED
DDLERROR 4080 IGNORE
DDLERROR 942 IGNORE
DDLERROR 4043 IGNORE
DDLERROR 1434 IGNORE
-- Initial state for Chapter 20 Add exercise.
MAP SOE.OPSTATUS, TARGET SOE.OPSTATUS;
PRM
chown ogg:ogg /u02/Deployment/etc/conf/ogg/fc01.prm /u02/Deployment/etc/conf/ogg/fc02.prm /u02/Deployment/etc/conf/ogg/fd01.prm /u02/Deployment/etc/conf/ogg/fd02.prm /u02/Deployment/etc/conf/ogg/fd03.prm
"

printf "\nCreate Chapter 20 Extract lanes and trails.\n"
run_admin "${OGGHUB_CONTAINER}" \
  "add extract FC01, integrated tranlog, begin now" \
  "add exttrail ${NORMAL_TRAIL}, extract FC01, megabytes 100" \
  "add extract FC02, integrated tranlog, begin now" \
  "add exttrail ${HEAVY_TRAIL}, extract FC02, megabytes 100"

printf "\nRegister Chapter 20 integrated Extract lanes.\n"
run_admin_batch "${OGGHUB_CONTAINER}" <<OGG
connect http://localhost:9011 deployment OGGHUB as oggadmin password WElcome1234## !
dblogin useridalias src_ogg domain ${DOMAIN}
register extract FC01 database
register extract FC02 database
exit
OGG

printf "\nStart Chapter 20 Extract lanes.\n"
run_admin "${OGGHUB_CONTAINER}" \
  "start FC01" \
  "start FC02"

printf "\nCreate and start Chapter 20 Replicat lanes.\n"
run_admin "${OGGHUB_CONTAINER}" \
  "add replicat FD01, exttrail ${NORMAL_TRAIL}, checkpointtable ${CHECKPOINT_TABLE}, begin now" \
  "add replicat FD02, exttrail ${HEAVY_TRAIL}, checkpointtable ${CHECKPOINT_TABLE}, begin now" \
  "add replicat FD03, exttrail ${HEAVY_TRAIL}, checkpointtable ${CHECKPOINT_TABLE}, begin now" \
  "start FD01" \
  "start FD02" \
  "start FD03"

printf "\nVerify Chapter 20 Data Fabric lanes.\n"
wait_group_stopped extract C01
wait_group_stopped replicat D01
wait_group_running extract FC01
wait_group_running extract FC02
wait_group_running replicat FD01
wait_group_running replicat FD02
wait_group_running replicat FD03
run_admin "${OGGHUB_CONTAINER}" \
  "info all"

printf "\nChapter 20 Data Fabric GoldenGate lanes reset and configured.\n"
printf "Open Data Fabric Canvas Design and click Refresh Metadata to reload topology metadata.\n"
lab_init_log_finish
