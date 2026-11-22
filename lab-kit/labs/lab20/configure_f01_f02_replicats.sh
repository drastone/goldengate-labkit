#!/bin/bash
set -euo pipefail

OGGHUB_CONTAINER="${OGGHUB_CONTAINER:-demo_ogg_23ai}"
TARGET_DB_CONTAINER="${TARGET_DB_CONTAINER:-demo_otrg_23ai}"
SOURCE_TRAIL="${SOURCE_TRAIL:-ca}"
DOMAIN="${DOMAIN:-OracleGoldenGate}"
CHECKPOINT_TABLE="${CHECKPOINT_TABLE:-OGG.GGSCKPT}"

printf "Configure Chapter 20 table-level Fabric Replicats\n"
printf "Host       : "; uname -n
printf "OGGHUB     : %s\n" "${OGGHUB_CONTAINER}"
printf "Trail      : %s\n" "${SOURCE_TRAIL}"
printf "\n"

run_admin() {
  container="$1"
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
print(text)
if "ERROR" in text.upper():
    sys.exit(1)
PY
  done
}

run_admin_ignore() {
  container="$1"
  shift

  if ! run_admin "${container}" "$@"; then
    printf "WARN: ignored Admin Client failure: %s\n" "$*" >&2
  fi
}

admin_output() {
  container="$1"
  cmd="$2"
  docker exec -i -u ogg "${container}" python3 - "${cmd}" <<'PY'
import sys
import json
import urllib.parse
import urllib.request

cmd = sys.argv[1]
url = "http://localhost:8765/api/adminclient?cmd=" + urllib.parse.quote(cmd)
payload = urllib.request.urlopen(url, timeout=60).read().decode()
try:
    data = json.loads(payload)
    print(data.get("output") or data.get("response", {}).get("reply") or payload)
except json.JSONDecodeError:
    print(payload)
PY
}

wait_not_running() {
  process_name="$1"
  attempts="${2:-12}"
  delay_seconds="${3:-5}"
  attempt=1

  while [ "${attempt}" -le "${attempts}" ]; do
    status_text="$(admin_output "${OGGHUB_CONTAINER}" "info replicat ${process_name}" 2>&1 || true)"
    if ! printf '%s\n' "${status_text}" | grep -Eiq 'Status RUNNING|RUNNING'; then
      printf "OK: Replicat %s is not running.\n" "${process_name}"
      return 0
    fi
    printf "... waiting for Replicat %s to stop (%s/%s).\n" "${process_name}" "${attempt}" "${attempts}"
    sleep "${delay_seconds}"
    attempt=$((attempt + 1))
  done

  printf "ERROR: Replicat %s is still running after %s seconds.\n" "${process_name}" "$((attempts * delay_seconds))" >&2
  return 1
}

verify_groups_absent() {
  status_text=""
  if ! status_text="$(admin_output "${OGGHUB_CONTAINER}" "info all")"; then
    printf "ERROR: could not verify removed GoldenGate process definitions.\n" >&2
    return 1
  fi
  for group_name in "$@"; do
    if printf '%s\n' "${status_text}" | grep -Eq "(EXTRACT|REPLICAT)[[:space:]]+[[:upper:]]+[[:space:]]+${group_name}([[:space:]]|$)"; then
      printf "ERROR: %s remains registered.\n" "${group_name}" >&2
      return 1
    fi
    printf "OK: %s is no longer registered.\n" "${group_name}"
  done
}

clear_replicat_checkpoints() {
  if [ "$(docker inspect -f '{{.State.Running}}' "${TARGET_DB_CONTAINER}" 2>/dev/null || true)" != "true" ]; then
    printf "ERROR: Target DB container must be running to clear Replicat checkpoints: %s\n" "${TARGET_DB_CONTAINER}" >&2
    return 1
  fi

  docker exec -i -u oracle "${TARGET_DB_CONTAINER}" bash -lc 'sqlplus -s / as sysdba' <<'SQL'
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
    execute immediate q'[delete from ogg.ggsckpt
                          where upper(group_name) in ('D01','F01','F02')]';
    l_rows := sql%rowcount;
    commit;
  end if;
  dbms_output.put_line('OK: cleared ' || l_rows || ' stale Replicat checkpoint row(s).');
end;
/
exit
SQL
}

printf "Stop and remove wildcard Replicat D01 if it exists.\n"
run_admin_ignore "${OGGHUB_CONTAINER}" "stop D01!"
wait_not_running D01

printf "\nStop and remove existing F01/F02 if they exist.\n"
run_admin_ignore "${OGGHUB_CONTAINER}" "stop F01!"
run_admin_ignore "${OGGHUB_CONTAINER}" "stop F02!"
wait_not_running F01
wait_not_running F02
run_admin_ignore "${OGGHUB_CONTAINER}" "delete replicat D01!"
run_admin_ignore "${OGGHUB_CONTAINER}" "delete replicat F01!"
run_admin_ignore "${OGGHUB_CONTAINER}" "delete replicat F02!"
verify_groups_absent D01 F01 F02
clear_replicat_checkpoints
printf "INFO: preserving active trail %s because C01 continues to own and write it.\n" "${SOURCE_TRAIL}"

printf "\nCreate table-level parameter files.\n"
docker exec -i -u root "${OGGHUB_CONTAINER}" bash -lc "cat > /u02/Deployment/etc/conf/ogg/f01.prm <<'PRM'
REPLICAT F01
CACHEMGR CACHESIZE 128M
USERIDALIAS trg_ogg DOMAIN OracleGoldenGate
ASSUMETARGETDEFS
APPLYNOOPUPDATES
DISCARDFILE F01_FABRIC.dsc, PURGE, MEGABYTES 100
REPORTCOUNT EVERY 1 MINUTES RATE
DDL INCLUDE MAPPED
DDLERROR 4080 IGNORE
DDLERROR 942 IGNORE
DDLERROR 4043 IGNORE
DDLERROR 1434 IGNORE
-- Heavy or batch-like insurance activity tables separated for Fabric lineage.
MAP SOE.CFUND_DT, TARGET SOE.CFUND_DT;
MAP SOE.OPSTATUS, TARGET SOE.OPSTATUS;
MAP SOE.TOT_AMT, TARGET SOE.TOT_AMT;
PRM
cat > /u02/Deployment/etc/conf/ogg/f02.prm <<'PRM'
REPLICAT F02
CACHEMGR CACHESIZE 128M
USERIDALIAS trg_ogg DOMAIN OracleGoldenGate
ASSUMETARGETDEFS
APPLYNOOPUPDATES
DISCARDFILE F02_FABRIC.dsc, PURGE, MEGABYTES 100
REPORTCOUNT EVERY 1 MINUTES RATE
DDL INCLUDE MAPPED
DDLERROR 4080 IGNORE
DDLERROR 942 IGNORE
DDLERROR 4043 IGNORE
DDLERROR 1434 IGNORE
-- Remaining SOE tables are mapped explicitly so the Fabric Designer can
-- derive table-level lineage instead of relying on MAP SOE.*.
MAP SOE.ADDRESS, TARGET SOE.ADDRESS;
MAP SOE.ADDRESS_BAK_BEFORE_ENRICH, TARGET SOE.ADDRESS_BAK_BEFORE_ENRICH;
MAP SOE.ADDRESS_BAK_SEOUL_20261008_125131, TARGET SOE.ADDRESS_BAK_SEOUL_20261008_125131;
MAP SOE.CALL_CENTER_LOG, TARGET SOE.CALL_CENTER_LOG;
MAP SOE.CANCELAMT, TARGET SOE.CANCELAMT;
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
chown ogg:ogg /u02/Deployment/etc/conf/ogg/f01.prm /u02/Deployment/etc/conf/ogg/f02.prm
"

printf "\nF01 parameter:\n"
docker exec -i "${OGGHUB_CONTAINER}" bash -lc "sed -n '1,80p' /u02/Deployment/etc/conf/ogg/f01.prm"
printf "\nF02 parameter first lines:\n"
docker exec -i "${OGGHUB_CONTAINER}" bash -lc "sed -n '1,120p' /u02/Deployment/etc/conf/ogg/f02.prm"

printf "\nCreate and start F01/F02 on the same source trail.\n"
run_admin "${OGGHUB_CONTAINER}" \
  "add replicat F01, exttrail ${SOURCE_TRAIL}, checkpointtable ${CHECKPOINT_TABLE}, begin now" \
  "add replicat F02, exttrail ${SOURCE_TRAIL}, checkpointtable ${CHECKPOINT_TABLE}, begin now" \
  "start F01" \
  "start F02" \
  "info all"

printf "\nVerify table-level Replicat configuration.\n"
run_admin "${OGGHUB_CONTAINER}" \
  "info replicat F01" \
  "info replicat F02"

printf "\nChapter 20 Fabric Replicats configured.\n"
