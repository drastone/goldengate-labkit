#!/bin/bash

if [ -z "${BASH_VERSION:-}" ] || shopt -qo posix 2>/dev/null; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  fi
  echo "ERROR: lab20_init.sh requires bash." >&2
  exit 1
fi

set -euo pipefail

OGGHUB_CONTAINER="${OGGHUB_CONTAINER:-demo_ogg_23ai}"
DOMAIN="${DOMAIN:-OracleGoldenGate}"
NORMAL_TRAIL="${NORMAL_TRAIL:-k1}"
HEAVY_TRAIL="${HEAVY_TRAIL:-k2}"

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
print("\n".join(lines).strip())
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
TABLE SOE.INS2_CHURN_FP_CARE_26AI;
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
MAP SOE.INS2_CHURN_FP_CARE_26AI, TARGET SOE.INS2_CHURN_FP_CARE_26AI;
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
  "add replicat FD01, exttrail ${NORMAL_TRAIL}, begin now" \
  "add replicat FD02, exttrail ${HEAVY_TRAIL}, begin now" \
  "add replicat FD03, exttrail ${HEAVY_TRAIL}, begin now" \
  "start FD01" \
  "start FD02" \
  "start FD03"

printf "\nVerify Chapter 20 Data Fabric lanes.\n"
run_admin "${OGGHUB_CONTAINER}" \
  "info all"

printf "\nChapter 20 Data Fabric GoldenGate lanes reset and configured.\n"
printf "Open Data Fabric Canvas Design and click Refresh Metadata to reload topology metadata.\n"
