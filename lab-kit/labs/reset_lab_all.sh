#!/bin/sh
set -eu

# Reset the lab GoldenGate path from the Host Linux layer.
#
# This script automates the manual reset flow documented in the OSA reset
# chapter. It intentionally stops and deletes OGG processes, removes local
# trail files, resets OSA sample objects and Kafka topics, then
# recreates and starts the OGG path.

LAB_HOME="${LAB_HOME:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)}"

OGGHUB_CONTAINER="${OGGHUB_CONTAINER:-demo_ogg_23ai}"
OGGBD_CONTAINER="${OGGBD_CONTAINER:-demo_oggbd_23ai}"
SOURCE_DB_CONTAINER="${SOURCE_DB_CONTAINER:-demo_osrc_23ai}"
TARGET_DB_CONTAINER="${TARGET_DB_CONTAINER:-demo_otrg_23ai}"
BIGDATA_CONTAINER="${BIGDATA_CONTAINER:-demo_centos}"

OGG_USER="${OGG_USER:-oggadmin}"
OGG_PASS="${OGG_PASS:-}"
SOURCE_DB_ALIAS="${SOURCE_DB_ALIAS:-src_ogg}"
TARGET_DB_ALIAS="${TARGET_DB_ALIAS:-trg_ogg}"
DOMAIN="${DOMAIN:-OracleGoldenGate}"

EXTRACT_NAME="${EXTRACT_NAME:-C01}"
ORACLE_REPLICAT_NAME="${ORACLE_REPLICAT_NAME:-D01}"
DISTPATH_NAME="${DISTPATH_NAME:-dpkaf01}"
KAFKA_REPLICAT_NAME="${KAFKA_REPLICAT_NAME:-KAF01}"

SOURCE_TRAIL="${SOURCE_TRAIL:-ca}"
TARGET_TRAIL="${TARGET_TRAIL:-da}"
TARGET_TRAIL_SIZE_MB="${TARGET_TRAIL_SIZE_MB:-100}"
OSA_SCRIPT_DIR="${OSA_SCRIPT_DIR:-/home/oracle/script/osa/23ai}"
D01_BASELINE_PARAM="${D01_BASELINE_PARAM:-${LAB_HOME}/../oracle/script/ogg/params/d01.prm}"
KAF01_BASELINE_PROPS="${KAF01_BASELINE_PROPS:-${LAB_HOME}/../oracle/script/oggbd/kafka/kaf01.props}"
KAF01_RUNTIME_PROPS="${KAF01_RUNTIME_PROPS:-/u02/Deployment/etc/conf/ogg/kaf01.props}"
CREATE_OBJECTS="${CREATE_OBJECTS:-N}"
YES="${YES:-N}"
RESET_SETTLE_SECONDS="${RESET_SETTLE_SECONDS:-10}"
TRAIL_WAIT_SECONDS="${TRAIL_WAIT_SECONDS:-60}"
PROCESS_WAIT_SECONDS="${PROCESS_WAIT_SECONDS:-60}"
PROCESS_WAIT_INTERVAL="${PROCESS_WAIT_INTERVAL:-3}"
TARGET_OBJECT_WAIT_SECONDS="${TARGET_OBJECT_WAIT_SECONDS:-120}"
PHASE="initializing"

finish_report() {
  status="$?"
  if [ "${status}" -ne 0 ]; then
    echo
    echo "ERROR: reset_lab_all.sh failed during phase: ${PHASE}" >&2
    echo "ERROR: exit status: ${status}" >&2
    echo "ERROR: C01/D01/KAF01/dpkaf01 may have been deleted but not recreated." >&2
    echo "ERROR: Review the output above, fix the failed phase, then rerun this script." >&2
  fi
}

trap finish_report EXIT

for arg in "$@"; do
  case "${arg}" in
    -y|--yes)
      YES="Y"
      ;;
    --create-objects)
      CREATE_OBJECTS="Y"
      ;;
    -h|--help)
      cat <<USAGE
Usage: $0 [--yes] [--create-objects]

Environment overrides:
  OGG_PASS, OGGHUB_CONTAINER, OGGBD_CONTAINER, SOURCE_DB_CONTAINER,
  TARGET_DB_CONTAINER, BIGDATA_CONTAINER, CREATE_OBJECTS
USAGE
      exit 0
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      exit 1
      ;;
  esac
done

is_yes() {
  case "${1:-}" in
    1|Y|y|YES|yes|TRUE|true|ON|on) return 0 ;;
    *) return 1 ;;
  esac
}

run_admin() {
  container="$1"
  shift

  docker exec -i -u ogg "${container}" python3 - "$@" <<'PY' || return $?
import os
import re
import subprocess
import sys

sys.path.insert(0, "/u01")
from ogg_api_server import CONNECT_CMD, OGG_BIN, OGG_HOME

commands = sys.argv[1:]
script = CONNECT_CMD + "\n" + "\n".join(commands) + "\nexit\n"
proc = subprocess.run(
    [OGG_BIN],
    input=script,
    capture_output=True,
    text=True,
    timeout=120,
    env={**os.environ, "OGG_HOME": OGG_HOME},
)
text = proc.stdout
if proc.stderr:
    text += "\n" + proc.stderr
print(text)
if (proc.returncode != 0
        or re.search(r"(?i)\bError:\s", text)
        or re.search(r"\bERROR\s+OGG-\d+", text)
        or re.search(r"(?i)\bInvalid command\b", text)):
    print("ERROR: Admin Client command sequence failed", file=sys.stderr)
    sys.exit(1)
PY
}

run_admin_ignore() {
  container="$1"
  shift

  if ! run_admin "${container}" "$@"; then
    echo "WARN: ignored Admin Client failure in ${container}: $*" >&2
  fi
}

verify_ogg_group_running() {
  container="$1"
  group_name="$2"

  output="$(run_admin "${container}" "info all")"
  printf '%s\n' "${output}"
  if ! printf '%s\n' "${output}" \
      | grep -Eq "(EXTRACT|REPLICAT)[[:space:]]+RUNNING[[:space:]]+${group_name}([[:space:]]|$)"; then
    echo "ERROR: ${group_name} is not RUNNING in ${container}." >&2
    return 1
  fi
}

verify_distpath_running() {
  container="$1"
  path_name="$2"

  output="$(run_admin "${container}" "info distpath all")"
  printf '%s\n' "${output}"
  if ! printf '%s\n' "${output}" \
      | grep -Eq "${path_name}[[:space:]]+running([[:space:]]|$)"; then
    echo "ERROR: Distribution Path ${path_name} is not running in ${container}." >&2
    return 1
  fi
}

run_in_container() {
  container="$1"
  shift

  echo "==> ${container}: $*"
  docker exec -u root "${container}" "$@"
}

force_kill_ogg_group() {
  container="$1"
  group_name="$2"

  echo "==> ${container}: ensure ${group_name} OS process is stopped"
  docker exec -u root "${container}" bash -lc "
    set -euo pipefail
    pids=\$(ps -ef | awk '/[P]ROCESSID[[:space:]]+${group_name}([[:space:]]|\$)/ {print \$2}')
    if [ -z \"\${pids}\" ]; then
      echo '${group_name}: no OS process found.'
      exit 0
    fi
    echo '${group_name}: TERM' \${pids}
    kill -TERM \${pids} 2>/dev/null || true
    sleep ${PROCESS_WAIT_INTERVAL}
    pids=\$(ps -ef | awk '/[P]ROCESSID[[:space:]]+${group_name}([[:space:]]|\$)/ {print \$2}')
    if [ -n \"\${pids}\" ]; then
      echo '${group_name}: KILL' \${pids}
      kill -KILL \${pids} 2>/dev/null || true
      sleep 1
    fi
  "
}

stop_osa_generators() {
  container="$1"

  echo "==> ${container}: stop OSA sample generator processes"
  docker exec -u root "${container}" bash -lc '
    set -euo pipefail
    pids=$(ps -ef | awk '"'"'
      /[s]h[[:space:]].*(gen_base|gen_0|gen_1|gen_3|gen_4|gen_5|gen_6|gen_opstatus|gen_totamt|gen_heartbp|gen_heartbeat)\.sh/ {print $2}
    '"'"')
    if [ -z "${pids}" ]; then
      echo "No OSA sample generator processes found."
      exit 0
    fi

    children=""
    for pid in ${pids}; do
      children="${children} $(pgrep -P "${pid}" 2>/dev/null || true)"
    done

    echo "TERM OSA generator pids:${pids}${children}"
    kill -TERM ${children} ${pids} 2>/dev/null || true
    sleep 3

    remaining=""
    for pid in ${pids} ${children}; do
      if [ -n "${pid}" ] && kill -0 "${pid}" 2>/dev/null; then
        remaining="${remaining} ${pid}"
      fi
    done

    if [ -n "${remaining}" ]; then
      echo "KILL remaining OSA generator pids:${remaining}"
      kill -KILL ${remaining} 2>/dev/null || true
    fi
  '
}

kill_osa_sqlplus_sessions() {
  container="$1"

  echo "==> ${container}: kill lingering SOE SQL*Plus sessions"
  docker exec -u oracle "${container}" bash -lc "
    sqlplus -s / as sysdba <<'SQL'
set serveroutput on
whenever sqlerror exit failure rollback
alter session set container=ORCLPDB1;

begin
  for cur in (
    select sid, serial#, username, module, program
    from v\$session
    where username = 'SOE'
      and sid != sys_context('USERENV', 'SID')
      and (
        module = 'SQL*Plus'
        or program like 'sqlplus%'
        or program like '%sqlplus%'
      )
    order by logon_time
  ) loop
    begin
      dbms_output.put_line('KILL SESSION ' || cur.sid || ',' || cur.serial# || ' ' || cur.program);
      execute immediate 'alter system kill session ''' || cur.sid || ',' || cur.serial# || ''' immediate';
      dbms_output.put_line('KILL SESSION DONE');
    exception
      when others then
        dbms_output.put_line('KILL SESSION FAILED: ' || sqlerrm);
    end;
  end loop;
end;
/
exit
SQL
  "
}

wait_for_no_ogg_group_process() {
  container="$1"
  group_name="$2"
  timeout_seconds="$3"
  deadline="$(( $(date '+%s') + timeout_seconds ))"

  echo "==> Wait for ${container} ${group_name} OS process to stop"
  while :; do
    if ! docker exec -u root "${container}" bash -lc \
      "ps -ef | awk '/[P]ROCESSID[[:space:]]+${group_name}([[:space:]]|\$)/ {found=1} END {exit found ? 0 : 1}'"; then
      return 0
    fi

    if [ "$(date '+%s')" -ge "${deadline}" ]; then
      echo "WARN: ${group_name} still has an OS process after ${timeout_seconds} seconds; forcing cleanup." >&2
      force_kill_ogg_group "${container}" "${group_name}"
      return 0
    fi

    sleep "${PROCESS_WAIT_INTERVAL}"
  done
}

wait_for_distpath_not_running() {
  container="$1"
  path_name="$2"
  timeout_seconds="$3"
  deadline="$(( $(date '+%s') + timeout_seconds ))"

  echo "==> Wait for ${container} distpath ${path_name} to stop or disappear"
  while :; do
    status="$(docker exec -i -u ogg "${container}" python3 - "${path_name}" <<'PY' || true
import sys
import urllib.parse
import urllib.request

path_name = sys.argv[1]
cmd = "info distpath all"
url = "http://localhost:8765/api/adminclient?cmd=" + urllib.parse.quote(cmd)
try:
    text = urllib.request.urlopen(url, timeout=20).read().decode(errors="replace")
except Exception as exc:
    print("ERROR " + repr(exc))
    sys.exit(0)
for line in text.splitlines():
    if path_name in line:
        print(line.strip())
        sys.exit(0)
print("NOT_FOUND")
PY
)"
    case "${status}" in
      *running*|*starting*)
        ;;
      *)
        return 0
        ;;
    esac

    if [ "$(date '+%s')" -ge "${deadline}" ]; then
      echo "WARN: distpath ${path_name} is still reported as '${status}' after ${timeout_seconds} seconds." >&2
      return 0
    fi

    sleep "${PROCESS_WAIT_INTERVAL}"
  done
}

run_script_as_oracle() {
  container="$1"
  script_name="$2"

  echo "==> ${container}: ${script_name}"
  docker exec -u oracle "${container}" bash -lc \
	    "cd '${OSA_SCRIPT_DIR}' && sh '${script_name}'"
}

wait_for_target_osa_objects() {
  timeout_seconds="$1"
  deadline="$(( $(date '+%s') + timeout_seconds ))"

  echo "==> Wait for target SOE sample objects"
  while :; do
    count="$(docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc "
      sqlplus -s / as sysdba <<'SQL'
set heading off feedback off pages 0 verify off echo off
alter session set container=ORCLPDB1;
select count(*)
from dba_objects
where owner = 'SOE'
  and object_type = 'TABLE'
  and status = 'VALID'
  and object_name in ('ADDRESS','CUST_PR','CANCELAMT','CALL_CENTER_LOG','CUST_INFO');
exit
SQL
    " | awk '/^[[:space:]]*[0-9]+[[:space:]]*$/ {print $1}' | tail -1)"

    if [ "${count:-0}" -eq 5 ]; then
      return 0
    fi

    if [ "$(date '+%s')" -ge "${deadline}" ]; then
      echo "ERROR: timed out waiting for target SOE sample objects; found ${count:-0}/5." >&2
      exit 1
    fi

    sleep "${PROCESS_WAIT_INTERVAL}"
  done
}

repair_target_ai_app_privileges() {
  echo "==> Repair target AI/APEX privileges and compile GGADMIN objects"
  docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc "
    sqlplus -s / as sysdba <<'SQL'
set serveroutput on
whenever sqlerror exit failure rollback
alter session set container=ORCLPDB1;

grant select on soe.address to ggadmin;
grant select on soe.cust_pr to ggadmin;
grant select on soe.cancelamt to ggadmin;
grant select on soe.call_center_log to ggadmin;
grant select on soe.cust_info to ggadmin;

begin
  dbms_utility.compile_schema(schema => 'GGADMIN', compile_all => false);
end;
/

declare
  l_invalid_count number;
begin
  select count(*)
    into l_invalid_count
    from dba_objects
   where owner = 'GGADMIN'
     and object_name like 'INS2_CHURN%'
     and status <> 'VALID';

  if l_invalid_count > 0 then
    raise_application_error(-20001, 'GGADMIN INS2_CHURN invalid objects remain: ' || l_invalid_count);
  end if;
end;
/
exit
SQL
  "
}

wait_for_trail_definition() {
  container="$1"
  trail_prefix="$2"
  timeout_seconds="$3"
  deadline="$(( $(date '+%s') + timeout_seconds ))"

  echo "==> Wait for ${container} trail definition ${trail_prefix}"
  while :; do
    if run_admin "${container}" "info exttrail ${trail_prefix}" \
      | grep -Eq "Local Trail:[[:space:]]*${trail_prefix}|Trail Name[[:space:]]+${trail_prefix}|${trail_prefix}"; then
      return 0
    fi

    if [ "$(date '+%s')" -ge "${deadline}" ]; then
      echo "ERROR: timed out waiting for trail definition ${trail_prefix} in ${container}" >&2
      exit 1
    fi

    sleep 2
  done
}

check_container() {
  container="$1"

  if ! docker inspect "${container}" >/dev/null 2>&1; then
    echo "ERROR: container not found: ${container}" >&2
    exit 1
  fi

  if [ "$(docker inspect -f '{{.State.Running}}' "${container}")" != "true" ]; then
    echo "ERROR: required container is not running: ${container}" >&2
    echo "ERROR: run /home/oracle/startDocker.sh, confirm the containers are healthy, then retry." >&2
    exit 1
  fi
}

START_EPOCH="$(date +%s)"
START_TIME="$(date '+%Y-%m-%d %H:%M:%S')"
HOST_NAME="$(uname -n 2>/dev/null || hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo unknown)"
CURRENT_DIR="$(pwd)"

cat <<SUMMARY
Reset GoldenGate lab environment
Start time          : ${START_TIME}
Host name           : ${HOST_NAME}
Working directory  : ${CURRENT_DIR}
OGGHUB container   : ${OGGHUB_CONTAINER}
OGGBD container    : ${OGGBD_CONTAINER}
Source DB container: ${SOURCE_DB_CONTAINER}
Target DB container: ${TARGET_DB_CONTAINER}
Kafka container    : ${BIGDATA_CONTAINER}

This will stop/delete ${EXTRACT_NAME}, ${ORACLE_REPLICAT_NAME}, ${DISTPATH_NAME}, ${KAFKA_REPLICAT_NAME},
remove ${SOURCE_TRAIL}*/${TARGET_TRAIL}* trail files, reset OSA sample
objects in Source/Target, reset OSA Kafka topics, then recreate and start the
OGG path. It does not create OSA sample objects unless --create-objects is used.

INFO: This reset usually takes a few minutes.
INFO: Some steps can look idle while Docker, Admin Client, database, or Kafka
INFO: commands are running. Please wait and do not type additional input unless
INFO: this script prompts you.
SUMMARY

if ! is_yes "${YES}"; then
  echo 'This reset deletes and recreates OGG processes, paths, trails, sample objects, and Kafka topics.'
  printf 'Press Enter for RESET, or type NO to cancel [RESET]: '
  read -r answer
  answer="${answer:-RESET}"
  if [ "${answer}" != "RESET" ] && [ "${answer}" != "Y" ] && [ "${answer}" != "YES" ] && [ "${answer}" != "y" ] && [ "${answer}" != "yes" ]; then
    echo "Canceled."
    exit 1
  fi
fi

if [ -z "${OGG_PASS}" ]; then
  printf 'OGG Password: '
  stty_state="$(stty -g 2>/dev/null || true)"
  stty -echo 2>/dev/null || true
  read -r OGG_PASS
  if [ -n "${stty_state}" ]; then
    stty "${stty_state}" 2>/dev/null || true
  else
    stty echo 2>/dev/null || true
  fi
  echo
fi

check_container "${OGGHUB_CONTAINER}"
check_container "${OGGBD_CONTAINER}"
check_container "${SOURCE_DB_CONTAINER}"
check_container "${TARGET_DB_CONTAINER}"
check_container "${BIGDATA_CONTAINER}"

echo
echo "==> Stop OGGHUB processes"
PHASE="stop OGGHUB processes"
run_admin_ignore "${OGGHUB_CONTAINER}" \
  "stop ${EXTRACT_NAME}!" \
  "stop ${ORACLE_REPLICAT_NAME}!" \
  "stop distpath ${DISTPATH_NAME}!" \
  "info all" \
  "info distpath all"

echo
echo "==> Stop OGGBD Replicat"
PHASE="stop OGGBD Replicat"
run_admin_ignore "${OGGBD_CONTAINER}" \
  "stop ${KAFKA_REPLICAT_NAME}!" \
  "info all"

wait_for_no_ogg_group_process "${OGGHUB_CONTAINER}" "${EXTRACT_NAME}" "${PROCESS_WAIT_SECONDS}"
wait_for_no_ogg_group_process "${OGGHUB_CONTAINER}" "${ORACLE_REPLICAT_NAME}" "${PROCESS_WAIT_SECONDS}"
wait_for_no_ogg_group_process "${OGGBD_CONTAINER}" "${KAFKA_REPLICAT_NAME}" "${PROCESS_WAIT_SECONDS}"
wait_for_distpath_not_running "${OGGHUB_CONTAINER}" "${DISTPATH_NAME}" "${PROCESS_WAIT_SECONDS}"

echo
echo "==> Delete OGGHUB Extract"
PHASE="delete OGGHUB Extract"
run_admin_ignore "${OGGHUB_CONTAINER}" \
  "dblogin useridalias ${SOURCE_DB_ALIAS} domain ${DOMAIN}" \
  "delete extract ${EXTRACT_NAME}!" \
  "info all"

echo
echo "==> Delete OGGHUB Oracle Replicat"
PHASE="delete OGGHUB Oracle Replicat"
run_admin_ignore "${OGGHUB_CONTAINER}" \
  "dblogin useridalias ${TARGET_DB_ALIAS} domain ${DOMAIN}" \
  "delete replicat ${ORACLE_REPLICAT_NAME}" \
  "info all"

echo
echo "==> Delete OGGHUB Distribution Path"
PHASE="delete OGGHUB Distribution Path"
run_admin_ignore "${OGGHUB_CONTAINER}" \
  "delete distpath ${DISTPATH_NAME}!" \
  "info distpath all"

echo
echo "==> Delete OGGBD Kafka Replicat"
PHASE="delete OGGBD Kafka Replicat"
run_admin_ignore "${OGGBD_CONTAINER}" \
  "delete replicat ${KAFKA_REPLICAT_NAME}!" \
  "info all"

wait_for_no_ogg_group_process "${OGGBD_CONTAINER}" "${KAFKA_REPLICAT_NAME}" "${PROCESS_WAIT_SECONDS}"
wait_for_distpath_not_running "${OGGHUB_CONTAINER}" "${DISTPATH_NAME}" "${PROCESS_WAIT_SECONDS}"

echo
echo "==> Wait for OGG processes, REST state, and trail file handles to settle"
echo "Sleeping ${RESET_SETTLE_SECONDS} seconds before removing trail files..."
sleep "${RESET_SETTLE_SECONDS}"

echo
echo "==> Remove OGGHUB trail ${SOURCE_TRAIL}*"
PHASE="remove OGGHUB trail"
run_in_container "${OGGHUB_CONTAINER}" bash -lc "
  set -euo pipefail
  cd /u02/Deployment/var/lib
  shopt -s nullglob
  files=(data/${SOURCE_TRAIL}*)
  if [ \${#files[@]} -gt 0 ]; then
    rm -f \"\${files[@]}\"
  else
    echo 'No ${SOURCE_TRAIL} trail files found.'
  fi
"

echo
echo "==> Remove OGGBD trail ${TARGET_TRAIL}*"
PHASE="remove OGGBD trail"
run_in_container "${OGGBD_CONTAINER}" bash -lc "
  set -euo pipefail
  cd /u02/Deployment/var/lib
  shopt -s nullglob
  files=(data/${TARGET_TRAIL}*)
  if [ \${#files[@]} -gt 0 ]; then
    rm -f \"\${files[@]}\"
  else
    echo 'No ${TARGET_TRAIL} trail files found.'
  fi
"

echo
echo "==> Reset OSA sample objects in Source and Target"
PHASE="reset OSA sample objects"
stop_osa_generators "${SOURCE_DB_CONTAINER}"
stop_osa_generators "${TARGET_DB_CONTAINER}"
kill_osa_sqlplus_sessions "${SOURCE_DB_CONTAINER}"
kill_osa_sqlplus_sessions "${TARGET_DB_CONTAINER}"
run_script_as_oracle "${SOURCE_DB_CONTAINER}" reset_osa_objects.sh
run_script_as_oracle "${TARGET_DB_CONTAINER}" reset_osa_objects.sh

echo
echo "==> Reset OSA Kafka topics"
PHASE="reset OSA Kafka topics"
BIGDATA_CONTAINER="${BIGDATA_CONTAINER}" sh "${LAB_HOME}/reset_osa_kafka_topics.sh"

echo
echo "==> Restore OGGBD Replicat ${KAFKA_REPLICAT_NAME} baseline properties"
PHASE="restore OGGBD Replicat ${KAFKA_REPLICAT_NAME} baseline properties"
if [ ! -f "${KAF01_BASELINE_PROPS}" ]; then
  echo "ERROR: KAF01 baseline properties not found: ${KAF01_BASELINE_PROPS}" >&2
  exit 1
fi
if ! grep -F '${objectname[TABLE_NAME]}' "${KAF01_BASELINE_PROPS}" >/dev/null 2>&1; then
  echo "ERROR: KAF01 baseline does not define the TABLE_NAME metadata alias." >&2
  exit 1
fi
docker cp "${KAF01_BASELINE_PROPS}" "${OGGBD_CONTAINER}:/tmp/kaf01.props.baseline"
run_in_container "${OGGBD_CONTAINER}" sh -c "
  set -eu
  cp /tmp/kaf01.props.baseline '${KAF01_RUNTIME_PROPS}'
  chown ogg:ogg '${KAF01_RUNTIME_PROPS}'
  chmod 640 '${KAF01_RUNTIME_PROPS}'
  rm -f /tmp/kaf01.props.baseline
  grep -F '\${objectname[TABLE_NAME]}' '${KAF01_RUNTIME_PROPS}'
"

echo
echo "==> Recreate OGGHUB Extract ${EXTRACT_NAME}"
PHASE="recreate OGGHUB Extract ${EXTRACT_NAME}"
run_admin "${OGGHUB_CONTAINER}" \
  "dblogin useridalias ${SOURCE_DB_ALIAS} domain ${DOMAIN}" \
  "add extract ${EXTRACT_NAME}, integrated tranlog, begin now" \
  "add exttrail ${SOURCE_TRAIL}, extract ${EXTRACT_NAME}, megabytes 100" \
  "register extract ${EXTRACT_NAME} database!" \
  "info all"

echo
echo "==> Start OGGHUB Extract ${EXTRACT_NAME}"
PHASE="start OGGHUB Extract ${EXTRACT_NAME}"
run_admin "${OGGHUB_CONTAINER}" \
  "start ${EXTRACT_NAME}" \
  "info all"

wait_for_trail_definition "${OGGHUB_CONTAINER}" "${SOURCE_TRAIL}" "${TRAIL_WAIT_SECONDS}"

echo
echo "==> Restore OGGHUB Replicat ${ORACLE_REPLICAT_NAME} baseline parameters"
PHASE="restore OGGHUB Replicat ${ORACLE_REPLICAT_NAME} baseline parameters"
if [ ! -f "${D01_BASELINE_PARAM}" ]; then
  echo "ERROR: D01 baseline parameter file not found: ${D01_BASELINE_PARAM}" >&2
  exit 1
fi
docker cp "${D01_BASELINE_PARAM}" "${OGGHUB_CONTAINER}:/tmp/d01-baseline.prm"
run_in_container "${OGGHUB_CONTAINER}" bash -lc "
  set -euo pipefail
  prm=/u02/Deployment/etc/conf/ogg/$(printf '%s' "${ORACLE_REPLICAT_NAME}" | tr '[:upper:]' '[:lower:]').prm
  install -m 640 -o ogg -g ogg /tmp/d01-baseline.prm \"\${prm}\"
  rm -f /tmp/d01-baseline.prm
"

echo "==> Harden OGGHUB Replicat ${ORACLE_REPLICAT_NAME} parameters"
PHASE="harden OGGHUB Replicat ${ORACLE_REPLICAT_NAME} parameters"
# These DDLERROR guards are reset-only hardening for repeated labs after the
# manual GoldenGate flow has already been learned. They intentionally are not
# part of the early chapter hand-entered D01 parameter baseline.
run_in_container "${OGGHUB_CONTAINER}" bash -lc "
  set -euo pipefail
  prm=/u02/Deployment/etc/conf/ogg/$(printf '%s' "${ORACLE_REPLICAT_NAME}" | tr '[:upper:]' '[:lower:]').prm
  if [ -f \"\${prm}\" ] && {
    ! grep -q '^DDLERROR 4080 IGNORE' \"\${prm}\" ||
    ! grep -q '^DDLERROR 942 IGNORE' \"\${prm}\" ||
    ! grep -q '^DDLERROR 4043 IGNORE' \"\${prm}\" ||
    ! grep -q '^DDLERROR 1434 IGNORE' \"\${prm}\";
  }; then
    awk '
      /^DDLERROR (4080|942|4043|1434) IGNORE/ { next }
      /^MAP / && !guards_added {
        print \"DDLERROR 4080 IGNORE\"
        print \"DDLERROR 942 IGNORE\"
        print \"DDLERROR 4043 IGNORE\"
        print \"DDLERROR 1434 IGNORE\"
        guards_added = 1
      }
      { print }
    ' \"\${prm}\" > /tmp/replicat.prm
    cp /tmp/replicat.prm \"\${prm}\"
    chown ogg:ogg \"\${prm}\"
  fi
  [ -f \"\${prm}\" ] && sed -n '1,80p' \"\${prm}\" || true
"

echo
echo "==> Recreate OGGHUB Replicat ${ORACLE_REPLICAT_NAME}"
PHASE="recreate OGGHUB Replicat ${ORACLE_REPLICAT_NAME}"
run_admin "${OGGHUB_CONTAINER}" \
  "add replicat ${ORACLE_REPLICAT_NAME}, exttrail ${SOURCE_TRAIL}, checkpointtable OGG.GGSCKPT, begin now" \
  "info all"

echo
echo "==> Start OGGHUB Replicat ${ORACLE_REPLICAT_NAME}"
PHASE="start OGGHUB Replicat ${ORACLE_REPLICAT_NAME}"
run_admin "${OGGHUB_CONTAINER}" \
  "start ${ORACLE_REPLICAT_NAME}" \
  "info all"

echo
echo "==> Recreate OGGHUB Distribution Path ${DISTPATH_NAME}"
PHASE="recreate OGGHUB Distribution Path ${DISTPATH_NAME}"
run_admin "${OGGHUB_CONTAINER}" \
  "add distpath ${DISTPATH_NAME} source trail://localhost:9013/services/v2/source?trail=${SOURCE_TRAIL} target ogg://${OGGBD_CONTAINER}:9014/services/v2/targets?trail=${TARGET_TRAIL} targettype recvsrvr authentication useridalias oggbd_admin domain ${DOMAIN}" \
  "alter distpath ${DISTPATH_NAME} target sizemb ${TARGET_TRAIL_SIZE_MB}" \
  "info distpath all"

echo
echo "==> Start OGGHUB Distribution Path ${DISTPATH_NAME}"
PHASE="start OGGHUB Distribution Path ${DISTPATH_NAME}"
run_admin_ignore "${OGGHUB_CONTAINER}" \
  "start distpath ${DISTPATH_NAME}" \
  "info distpath all"

echo "INFO: ${TARGET_TRAIL} trail file may be created only after new source records arrive."

echo
echo "==> Recreate OGGBD Replicat ${KAFKA_REPLICAT_NAME}"
PHASE="recreate OGGBD Replicat ${KAFKA_REPLICAT_NAME}"
run_admin "${OGGBD_CONTAINER}" \
  "add replicat ${KAFKA_REPLICAT_NAME}, exttrail ${TARGET_TRAIL}, begin now" \
  "info all"

echo
echo "==> Start OGGBD Replicat"
PHASE="start OGGBD Replicat ${KAFKA_REPLICAT_NAME}"
run_admin "${OGGBD_CONTAINER}" \
  "start ${KAFKA_REPLICAT_NAME}" \
  "info all"

echo
echo "==> Verify recreated GoldenGate path"
PHASE="verify recreated GoldenGate path"
sleep 3
verify_ogg_group_running "${OGGHUB_CONTAINER}" "${EXTRACT_NAME}"
verify_ogg_group_running "${OGGHUB_CONTAINER}" "${ORACLE_REPLICAT_NAME}"
verify_distpath_running "${OGGHUB_CONTAINER}" "${DISTPATH_NAME}"
verify_ogg_group_running "${OGGBD_CONTAINER}" "${KAFKA_REPLICAT_NAME}"

if is_yes "${CREATE_OBJECTS}"; then
  echo
  echo "==> Create OSA sample objects from Source DB"
  PHASE="create OSA sample objects from Source DB"
  run_script_as_oracle "${SOURCE_DB_CONTAINER}" create_objects_v1_2.sh

  echo
  echo "==> Prepare 26ai AI demo candidates from Source DB"
  PHASE="prepare 26ai AI demo candidates from Source DB"
  run_script_as_oracle "${SOURCE_DB_CONTAINER}" prepare_ai_26ai_demo.sh

  echo
  PHASE="repair target AI/APEX privileges"
  wait_for_target_osa_objects "${TARGET_OBJECT_WAIT_SECONDS}"
  repair_target_ai_app_privileges

  echo
  echo "==> Verify OGGHUB Extract and Replicat statistics"
  run_admin "${OGGHUB_CONTAINER}" \
    "stats extract ${EXTRACT_NAME} totalsonly soe.*" \
    "stats replicat ${ORACLE_REPLICAT_NAME} totalsonly soe.*"

  echo
  echo "==> Verify OGGBD Replicat statistics"
  run_admin "${OGGBD_CONTAINER}" \
    "stats replicat ${KAFKA_REPLICAT_NAME} totalsonly soe.*"
else
  echo
  echo "INFO: OSA sample object creation is intentionally skipped."
  echo "INFO: Run create_objects_v1_2.sh manually in the next lab step."
fi

END_EPOCH="$(date +%s)"
END_TIME="$(date '+%Y-%m-%d %H:%M:%S')"
ELAPSED="$((END_EPOCH - START_EPOCH))"

echo
echo "End time: ${END_TIME}"
echo "Elapsed time: ${ELAPSED} seconds"
echo "GoldenGate lab environment reset completed."
