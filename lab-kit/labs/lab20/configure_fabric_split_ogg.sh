#!/bin/bash
set -euo pipefail

OGGHUB_CONTAINER="${OGGHUB_CONTAINER:-demo_ogg_23ai}"
TARGET_DB_CONTAINER="${TARGET_DB_CONTAINER:-demo_otrg_23ai}"
DOMAIN="${DOMAIN:-OracleGoldenGate}"
BASE_TRAIL="${BASE_TRAIL:-ca}"
NORMAL_TRAIL="${NORMAL_TRAIL:-k1}"
HEAVY_TRAIL="${HEAVY_TRAIL:-k2}"
CHECKPOINT_TABLE="${CHECKPOINT_TABLE:-OGG.GGSCKPT}"
RESET_SETTLE_SECONDS="${RESET_SETTLE_SECONDS:-5}"

printf "Configure Chapter 20 split Fabric GoldenGate path\n"
printf "Host        : "; uname -n
printf "OGGHUB      : %s\n" "${OGGHUB_CONTAINER}"
printf "Base trail  : %s\n" "${BASE_TRAIL}"
printf "Normal trail: %s\n" "${NORMAL_TRAIL}"
printf "Heavy trail : %s\n" "${HEAVY_TRAIL}"
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
  process_type="$1"
  process_name="$2"
  attempts="${3:-12}"
  delay_seconds="${4:-5}"
  i=1

  while [ "${i}" -le "${attempts}" ]; do
    status_text="$(admin_output "${OGGHUB_CONTAINER}" "info ${process_type} ${process_name}" 2>&1 || true)"
    if ! printf "%s\n" "${status_text}" | grep -Eiq 'Status RUNNING|RUNNING'; then
      printf "OK: %s %s is not running.\n" "${process_type}" "${process_name}"
      return 0
    fi
    printf "... waiting for %s %s to leave RUNNING state (%s/%s).\n" "${process_type}" "${process_name}" "${i}" "${attempts}"
    sleep "${delay_seconds}"
    i=$((i + 1))
  done

  printf "ERROR: %s %s is still running after %s seconds.\n" "${process_type}" "${process_name}" "$((attempts * delay_seconds))" >&2
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
      printf "ERROR: %s remains registered; refusing to remove its trail.\n" "${group_name}" >&2
      return 1
    fi
    printf "OK: %s is no longer registered.\n" "${group_name}"
  done
}

restart_adminsrvr() {
  attempts="${1:-40}"
  delay_seconds="${2:-2}"

  run_admin_batch "${OGGHUB_CONTAINER}" <<'OGG'
connect http://localhost as oggadmin password WElcome1234## !
restart service adminsrvr
exit
OGG

  i=1
  while [ "${i}" -le "${attempts}" ]; do
    if admin_output "${OGGHUB_CONTAINER}" "info all" >/dev/null 2>&1; then
      printf "OK: Administration Service restarted and is ready.\n"
      return 0
    fi
    printf "... waiting for Administration Service after restart (%s/%s).\n" "${i}" "${attempts}"
    sleep "${delay_seconds}"
    i=$((i + 1))
  done

  printf "ERROR: Administration Service did not become ready after restart.\n" >&2
  return 1
}

run_admin_batch() {
  container="$1"
  docker exec -i -u ogg "${container}" bash -lc "cd /u01/ogg && ./bin/adminclient"
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
                          where upper(group_name) in ('D01','F01','F02','FD01','FD02','FD03')]';
    l_rows := sql%rowcount;
    commit;
  end if;
  dbms_output.put_line('OK: cleared ' || l_rows || ' stale Replicat checkpoint row(s).');
end;
/
exit
SQL
}

printf "Stop and remove previous Chapter 20 split/wildcard processes if they exist.\n"
for grp in D01 F01 F02 FD01 FD02 FD03; do
  run_admin_ignore "${OGGHUB_CONTAINER}" "stop ${grp}!"
  wait_not_running replicat "${grp}"
done
for grp in D01 F01 F02 FD01 FD02 FD03; do
  run_admin_ignore "${OGGHUB_CONTAINER}" "delete replicat ${grp}!"
done
verify_groups_absent D01 F01 F02 FD01 FD02 FD03
clear_replicat_checkpoints

printf "\nStop previous baseline/split Extracts if they exist.\n"
for grp in C01 C02 FC01 FC02; do
  run_admin_ignore "${OGGHUB_CONTAINER}" "stop ${grp}!"
  wait_not_running extract "${grp}"
done

printf "\nUnregister previous integrated Extract metadata if it exists.\n"
set +e
run_admin_batch "${OGGHUB_CONTAINER}" <<OGG
connect http://localhost:9011 deployment OGGHUB as oggadmin password WElcome1234## !
dblogin useridalias src_ogg domain ${DOMAIN}
unregister extract C01 database
unregister extract C02 database
unregister extract FC01 database
unregister extract FC02 database
exit
OGG
set -e

for grp in C01 C02 FC01 FC02; do
  run_admin_ignore "${OGGHUB_CONTAINER}" "delete extract ${grp}!"
done
verify_groups_absent C01 C02 FC01 FC02

printf "\nRestart Administration Service to clear deleted process handles before reusing trail names.\n"
restart_adminsrvr
verify_groups_absent D01 F01 F02 FD01 FD02 FD03 C01 C02 FC01 FC02

printf "\nWait for process handles to settle and remove the trails owned by this full-path reset.\n"
sleep "${RESET_SETTLE_SECONDS}"
docker exec -i -u root "${OGGHUB_CONTAINER}" bash -lc "
set -euo pipefail
cd /u02/Deployment/var/lib
shopt -s nullglob
files=(data/${BASE_TRAIL}* data/${NORMAL_TRAIL}* data/${HEAVY_TRAIL}*)
if [ \${#files[@]} -gt 0 ]; then
  rm -f \"\${files[@]}\"
  echo 'OK: removed stale Fabric trails ${BASE_TRAIL}*, ${NORMAL_TRAIL}*, and ${HEAVY_TRAIL}*.'
else
  echo 'SKIP: no stale Fabric trail files were found.'
fi
"

printf "\nCreate Fabric split parameter files.\n"
docker exec -i -u root "${OGGHUB_CONTAINER}" bash -lc "cat > /u02/Deployment/etc/conf/ogg/c01.prm <<'PRM'
EXTRACT C01
USERIDALIAS src_ogg DOMAIN OracleGoldenGate
TRANLOGOPTIONS INTEGRATEDPARAMS (max_sga_size 256)
UPDATERECORDFORMAT COMPACT
DDL INCLUDE MAPPED
EXTTRAIL ca
TABLE SOE.*;
PRM
cat > /u02/Deployment/etc/conf/ogg/fc01.prm <<'PRM'
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
TABLE SOE.CANCELAMT;
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
-- Heavy or batch-like insurance activity tables are isolated.
TABLE SOE.CFUND_DT;
TABLE SOE.OPSTATUS;
TABLE SOE.TOT_AMT;
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
-- High-volume fund activity table from k2.
MAP SOE.CFUND_DT, TARGET SOE.CFUND_DT;
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
-- Operational/status heavy tables from k2.
MAP SOE.OPSTATUS, TARGET SOE.OPSTATUS;
MAP SOE.TOT_AMT, TARGET SOE.TOT_AMT;
PRM
chown ogg:ogg /u02/Deployment/etc/conf/ogg/c01.prm /u02/Deployment/etc/conf/ogg/fc01.prm /u02/Deployment/etc/conf/ogg/fc02.prm /u02/Deployment/etc/conf/ogg/fd01.prm /u02/Deployment/etc/conf/ogg/fd02.prm /u02/Deployment/etc/conf/ogg/fd03.prm
"

printf "\nC01 parameter restored:\n"
docker exec -i "${OGGHUB_CONTAINER}" bash -lc "sed -n '1,40p' /u02/Deployment/etc/conf/ogg/c01.prm"
printf "\nFC01 parameter first lines:\n"
docker exec -i "${OGGHUB_CONTAINER}" bash -lc "sed -n '1,120p' /u02/Deployment/etc/conf/ogg/fc01.prm"
printf "\nFC02 parameter:\n"
docker exec -i "${OGGHUB_CONTAINER}" bash -lc "sed -n '1,80p' /u02/Deployment/etc/conf/ogg/fc02.prm"
printf "\nFD01 parameter first lines:\n"
docker exec -i "${OGGHUB_CONTAINER}" bash -lc "sed -n '1,120p' /u02/Deployment/etc/conf/ogg/fd01.prm"
printf "\nFD02 parameter:\n"
docker exec -i "${OGGHUB_CONTAINER}" bash -lc "sed -n '1,80p' /u02/Deployment/etc/conf/ogg/fd02.prm"
printf "\nFD03 parameter:\n"
docker exec -i "${OGGHUB_CONTAINER}" bash -lc "sed -n '1,80p' /u02/Deployment/etc/conf/ogg/fd03.prm"

printf "\nCreate split Extracts and trails.\n"
run_admin "${OGGHUB_CONTAINER}" \
  "add extract C01, integrated tranlog, begin now" \
  "add extract FC01, integrated tranlog, begin now" \
  "add extract FC02, integrated tranlog, begin now"

run_admin "${OGGHUB_CONTAINER}" \
  "add exttrail ${BASE_TRAIL}, extract C01, megabytes 100" \
  "add exttrail ${NORMAL_TRAIL}, extract FC01, megabytes 100" \
  "add exttrail ${HEAVY_TRAIL}, extract FC02, megabytes 100"

printf "\nRegister split integrated Extracts in one Admin Client session.\n"
run_admin_batch "${OGGHUB_CONTAINER}" <<OGG
connect http://localhost:9011 deployment OGGHUB as oggadmin password WElcome1234## !
dblogin useridalias src_ogg domain ${DOMAIN}
register extract C01 database
register extract FC01 database
register extract FC02 database
exit
OGG

run_admin "${OGGHUB_CONTAINER}" \
  "start C01" \
  "start FC01" \
  "start FC02"

printf "\nCreate split Replicats.\n"
run_admin "${OGGHUB_CONTAINER}" \
  "add replicat FD01, exttrail ${NORMAL_TRAIL}, checkpointtable ${CHECKPOINT_TABLE}, begin now" \
  "add replicat FD02, exttrail ${HEAVY_TRAIL}, checkpointtable ${CHECKPOINT_TABLE}, begin now" \
  "add replicat FD03, exttrail ${HEAVY_TRAIL}, checkpointtable ${CHECKPOINT_TABLE}, begin now" \
  "start FD01" \
  "start FD02" \
  "start FD03" \
  "info all"

printf "\nVerify Fabric split GoldenGate configuration.\n"
run_admin "${OGGHUB_CONTAINER}" \
  "info extract C01" \
  "info extract FC01" \
  "info extract FC02" \
  "info replicat FD01" \
  "info replicat FD02" \
  "info replicat FD03"

printf "\nChapter 20 split Fabric GoldenGate path configured.\n"
