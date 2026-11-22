#!/bin/sh
set -eu

# Reset the lab GoldenGate path from the Host Linux layer.
#
# This script automates the manual reset flow documented in the OSA reset
# chapter. It intentionally stops and deletes OGG processes, removes local
# trail files, resets OSA sample objects and Kafka topics, then
# recreates and starts the OGG path.

LAB_HOME="${LAB_HOME:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)}"
BASE_LAB_HOME="${BASE_LAB_HOME:-$(CDPATH= cd -- "${LAB_HOME}/.." && pwd)}"
AUTO_START_REQUIRED_CONTAINERS="${AUTO_START_REQUIRED_CONTAINERS:-Y}"
CONTAINER_PREPARE_ONLY="${CONTAINER_PREPARE_ONLY:-N}"
REQUIRED_CONTAINER_WAIT_SECONDS="${REQUIRED_CONTAINER_WAIT_SECONDS:-180}"
RESET_ORACLE_TARGET="${RESET_ORACLE_TARGET:-N}"
BIGDATA_INIT_SCRIPT="${BIGDATA_INIT_SCRIPT:-${BASE_LAB_HOME}/centos/init.sh}"
KAFKA_READY_WAIT_SECONDS="${KAFKA_READY_WAIT_SECONDS:-240}"
KAFKA_HOME="${KAFKA_HOME:-/usr/local/kafka}"
FLOW_WAIT_SECONDS="${FLOW_WAIT_SECONDS:-240}"

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
STALE_OGGHUB_EXTRACTS="${STALE_OGGHUB_EXTRACTS:-C02 FC01 FC02}"
STALE_OGGHUB_REPLICATS="${STALE_OGGHUB_REPLICATS:-F01 F02 FD01 FD02 FD03}"
STALE_OGGHUB_TRAILS="${STALE_OGGHUB_TRAILS:-k1 k2}"
TARGET_TRAIL_SIZE_MB="${TARGET_TRAIL_SIZE_MB:-100}"
OSA_SCRIPT_DIR="${OSA_SCRIPT_DIR:-/home/oracle/script/osa/23ai}"
HOST_OSA_SCRIPT_DIR="${HOST_OSA_SCRIPT_DIR:-${BASE_LAB_HOME}/oracle/script/osa/23ai}"
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
RESET_WORK_STARTED="N"

finish_report() {
  status="$?"
  if [ "${status}" -ne 0 ]; then
    echo
    echo "ERROR: reset_lab_all.sh failed during phase: ${PHASE}" >&2
    echo "ERROR: exit status: ${status}" >&2
    if [ "${RESET_WORK_STARTED}" != "Y" ]; then
      echo "INFO: reset work did not start; no OGG process, trail, object, or topic was changed." >&2
    else
      echo "ERROR: C01/KAF01/dpkaf01 may have been deleted but not recreated." >&2
    fi
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
  TARGET_DB_CONTAINER, BIGDATA_CONTAINER, CREATE_OBJECTS,
  AUTO_START_REQUIRED_CONTAINERS, RESET_ORACLE_TARGET
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

  docker exec -i -u ogg \
    -e OGG_USER="${OGG_USER}" \
    -e OGG_PASS="${OGG_PASS}" \
    "${container}" python3 - "$@" <<'PY' || return $?
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
text = re.sub(r"(?im)(\bpassword\s+)\S+", r"\1********", text)
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

ogg_group_exists() {
  container="$1"
  group_name="$2"
  output="$(run_admin "${container}" "info all" 2>/dev/null || true)"
  printf '%s\n' "${output}" | grep -Eq "(EXTRACT|REPLICAT)[[:space:]]+[[:upper:]]+[[:space:]]+${group_name}([[:space:]]|$)"
}

verify_ogg_group_absent() {
  container="$1"
  group_name="$2"

  if ! output="$(run_admin "${container}" "info all")"; then
    echo "ERROR: could not verify that ${group_name} was removed from ${container}." >&2
    return 1
  fi
  if printf '%s\n' "${output}" | grep -Eq "(EXTRACT|REPLICAT)[[:space:]]+[[:upper:]]+[[:space:]]+${group_name}([[:space:]]|$)"; then
    printf '%s\n' "${output}" >&2
    echo "ERROR: ${group_name} remains registered in ${container}; refusing to remove its trail." >&2
    return 1
  fi
  echo "OK: ${group_name} is no longer registered in ${container}."
}

verify_distpath_absent() {
  container="$1"
  path_name="$2"

  if ! output="$(run_admin "${container}" "info distpath all")"; then
    echo "ERROR: could not verify that Distribution Path ${path_name} was removed." >&2
    return 1
  fi
  if printf '%s\n' "${output}" | grep -Eq "(^|[[:space:]])${path_name}([[:space:]]|$)"; then
    printf '%s\n' "${output}" >&2
    echo "ERROR: Distribution Path ${path_name} remains registered; refusing to remove its trail." >&2
    return 1
  fi
  echo "OK: Distribution Path ${path_name} is no longer registered."
}

wait_for_kafka_source_data() {
  deadline="$(( $(date '+%s') + FLOW_WAIT_SECONDS ))"
  attempt=1

  echo "==> Wait for live C01 -> ${DISTPATH_NAME} -> ${KAFKA_REPLICAT_NAME} delivery"
  while :; do
    offset="$(docker exec "${BIGDATA_CONTAINER}" bash -lc \
      "timeout 15 '${KAFKA_HOME}/bin/kafka-get-offsets.sh' --bootstrap-server localhost:9092 --topic SOE.CFUND_DT --time -1" \
      2>/dev/null | awk -F: '{sum += $3} END {print sum + 0}' || true)"
    case "${offset}" in
      ''|*[!0-9]*) offset=0 ;;
    esac
    if [ "${offset}" -gt 0 ]; then
      echo "OK: live GoldenGate delivery reached SOE.CFUND_DT at offset ${offset} (attempt ${attempt})."
      return 0
    fi
    if [ "$(date '+%s')" -ge "${deadline}" ]; then
      echo "ERROR: SOE.CFUND_DT remained empty after ${FLOW_WAIT_SECONDS} seconds." >&2
      return 1
    fi
    echo "INFO: waiting for live GoldenGate delivery to SOE.CFUND_DT (attempt ${attempt})."
    sleep 5
    attempt=$((attempt + 1))
  done
}

emit_kafka_flow_probe() {
  probe_key="$(date '+%s')"

  echo "==> Emit a transient SOE.CFUND_DT delivery probe"
  docker exec -i -u oracle "${SOURCE_DB_CONTAINER}" bash -lc \
    "sqlplus -L -s soe/soe@orclpdb1" <<SQL
whenever oserror exit failure
whenever sqlerror exit sql.sqlcode
set feedback off heading off pagesize 0 verify off

delete from soe.cfund_dt
 where cust_id = -999999
   and op_gubun = 'V';
commit;

insert into soe.cfund_dt (
  dt, keys, cust_id, fund_code, fund_name, fund_price, fund_cnt,
  fund_amt, fund_description, op_gubun, op_gubun2, cnt, start_dt
) values (
  to_char(sysdate, 'YYYYMMDD'), ${probe_key}, -999999,
  'LABKIT_FLOW_PROBE', 'Lab Kit flow probe', '0', 0,
  0, 'Transient end-to-end delivery probe', 'V', 'V', 1,
  to_char(sysdate, 'YYYYMMDDHH24MISS')
);
commit;

delete from soe.cfund_dt
 where cust_id = -999999
   and op_gubun = 'V';
commit;

exit
SQL
  echo "OK: transient SOE.CFUND_DT delivery probe committed and removed from Source."
}

run_stats_with_retry() {
  container="$1"
  command_text="$2"
  label="$3"
  attempts="${4:-12}"
  delay_seconds="${5:-5}"
  attempt=1

  while [ "${attempt}" -le "${attempts}" ]; do
    if output="$(run_admin "${container}" "${command_text}" 2>&1)"; then
      printf '%s\n' "${output}"
      echo "OK: ${label} statistics are available (attempt ${attempt}/${attempts})."
      return 0
    fi
    if ! printf '%s\n' "${output}" | grep -q 'OGG-15149'; then
      printf '%s\n' "${output}" >&2
      echo "ERROR: ${label} statistics failed for a reason other than initialization." >&2
      return 1
    fi
    echo "INFO: ${label} is still initializing; retry statistics in ${delay_seconds}s (${attempt}/${attempts})."
    sleep "${delay_seconds}"
    attempt=$((attempt + 1))
  done

  printf '%s\n' "${output}" >&2
  echo "ERROR: ${label} statistics remained unavailable after $((attempts * delay_seconds)) seconds." >&2
  return 1
}

verify_database_login() {
  container="$1"
  label="$2"
  login="$3"

  if ! docker exec -i -u oracle "${container}" bash -lc \
      "printf 'exit\\n' | sqlplus -L -s '${login}@orclpdb1'" \
      >/dev/null 2>&1; then
    echo "ERROR: ${label} database login is not ready: ${login%%/*}/<documented-password>." >&2
    echo "ERROR: Complete the Chapter 5 Source/Target database preparation, then rerun this reset." >&2
    return 1
  fi
}

verify_credential_alias_login() {
  alias_name="$1"

  if ! run_admin "${OGGHUB_CONTAINER}" \
      "dblogin useridalias ${alias_name} domain ${DOMAIN}" >/dev/null; then
    echo "ERROR: GoldenGate database credential alias is not ready: ${alias_name}." >&2
    echo "ERROR: Complete the Chapter 6 credential-store procedure, then rerun this reset." >&2
    return 1
  fi
}

verify_reset_prerequisites() {
  echo "==> Verify database accounts and GoldenGate credential aliases"
  verify_database_login "${SOURCE_DB_CONTAINER}" "Source SOE" "soe/soe"
  verify_database_login "${SOURCE_DB_CONTAINER}" "Source OGG" "ogg/ogg"
  verify_credential_alias_login "${SOURCE_DB_ALIAS}"

  if is_yes "${ORACLE_TARGET_ACTIVE}"; then
    verify_database_login "${TARGET_DB_CONTAINER}" "Target SOE" "soe/soe"
    verify_database_login "${TARGET_DB_CONTAINER}" "Target OGG" "ogg/ogg"
    verify_credential_alias_login "${TARGET_DB_ALIAS}"
  fi
  echo "OK: database accounts and GoldenGate credential aliases are ready."
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

sync_source_osa_scripts() {
  required_files="
reset_osa_objects.sh
prepare_osa_source_objects.sh
call_center_log_inserts.sql
cfund_ratio.sql
prepare_ai_26ai_demo.sh
"

  echo "==> Sync canonical OSA scripts to ${SOURCE_DB_CONTAINER}"
  for file_name in ${required_files}; do
    source_file="${HOST_OSA_SCRIPT_DIR}/${file_name}"
    if [ ! -f "${source_file}" ]; then
      echo "ERROR: required host OSA file is missing: ${source_file}" >&2
      echo "ERROR: restore the current Lab Kit files, then rerun this reset." >&2
      return 1
    fi
  done

  docker exec -u root "${SOURCE_DB_CONTAINER}" mkdir -p "${OSA_SCRIPT_DIR}"
  for file_name in ${required_files}; do
    docker cp "${HOST_OSA_SCRIPT_DIR}/${file_name}" \
      "${SOURCE_DB_CONTAINER}:${OSA_SCRIPT_DIR}/${file_name}"
  done
  docker exec -u root "${SOURCE_DB_CONTAINER}" \
    chown oracle:oinstall \
      "${OSA_SCRIPT_DIR}/reset_osa_objects.sh" \
      "${OSA_SCRIPT_DIR}/prepare_osa_source_objects.sh" \
      "${OSA_SCRIPT_DIR}/call_center_log_inserts.sql" \
      "${OSA_SCRIPT_DIR}/cfund_ratio.sql" \
      "${OSA_SCRIPT_DIR}/prepare_ai_26ai_demo.sh"
  docker exec -u root "${SOURCE_DB_CONTAINER}" \
    chmod 0755 \
      "${OSA_SCRIPT_DIR}/reset_osa_objects.sh" \
      "${OSA_SCRIPT_DIR}/prepare_osa_source_objects.sh" \
      "${OSA_SCRIPT_DIR}/prepare_ai_26ai_demo.sh"

  for file_name in ${required_files}; do
    if ! docker exec "${SOURCE_DB_CONTAINER}" \
        test -f "${OSA_SCRIPT_DIR}/${file_name}"; then
      echo "ERROR: OSA file was not staged in ${SOURCE_DB_CONTAINER}: ${file_name}" >&2
      return 1
    fi
  done
  echo "OK: canonical OSA scripts are current in ${SOURCE_DB_CONTAINER}."
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

grant_target_apex_source_privileges() {
  echo "==> Grant APEX parsing access to replicated Target SOE objects"
  docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc "
    sqlplus -s / as sysdba <<'SQL'
set serveroutput on
whenever sqlerror exit failure rollback
alter session set container=ORCLPDB1;

declare
  l_count number;
begin
  select count(*) into l_count
  from dba_users
  where username = 'GGADMIN';

  if l_count = 0 then
    dbms_output.put_line('SKIP: GGADMIN is not installed; APEX grants are not required before the APEX lab.');
  else
    execute immediate 'grant select on soe.address to ggadmin';
    execute immediate 'grant select on soe.cust_pr to ggadmin';
    execute immediate 'grant select on soe.cancelamt to ggadmin';
    execute immediate 'grant select on soe.call_center_log to ggadmin';
    execute immediate 'grant select on soe.cust_info to ggadmin';
    dbms_output.put_line('OK: Target SOE read grants applied to GGADMIN.');
  end if;
end;
/

exit
SQL
  "
}

ensure_target_ogg_identity_ddl_privilege() {
  echo "==> Ensure Target OGG can apply identity-column table DDL"
  docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc "
    sqlplus -s / as sysdba <<'SQL'
whenever sqlerror exit failure rollback
alter session set container=ORCLPDB1;
grant create any sequence to ogg;
exit
SQL
  "
}

remove_source_legacy_ai_objects() {
  echo "==> Remove retired Source SOE analytics objects"
  docker exec -u oracle "${SOURCE_DB_CONTAINER}" bash -lc "
    sqlplus -s / as sysdba <<'SQL'
whenever sqlerror exit failure rollback
alter session set container=ORCLPDB1;
begin
  for r in (
    select 'drop view soe.ins2_churn_action_queue_26ai_v' ddl from dual
    union all
    select 'drop package soe.ins2_churn_fp_ai_pkg' from dual
    union all
    select 'drop table soe.ins2_churn_fp_care_26ai cascade constraints purge' from dual
  ) loop
    begin
      execute immediate r.ddl;
    exception
      when others then
        if sqlcode not in (-942, -4043) then
          raise;
        end if;
    end;
  end loop;
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

container_is_running() {
  container="$1"
  [ "$(docker inspect -f '{{.State.Running}}' "${container}" 2>/dev/null || true)" = "true" ]
}

check_container_exists() {
  container="$1"

  if ! docker inspect "${container}" >/dev/null 2>&1; then
    echo "ERROR: container not found: ${container}" >&2
    exit 1
  fi
}

ensure_required_containers_running() {
  missing=""

  for container in \
      "${OGGHUB_CONTAINER}" \
      "${OGGBD_CONTAINER}" \
      "${SOURCE_DB_CONTAINER}" \
      "${BIGDATA_CONTAINER}"; do
    if ! container_is_running "${container}"; then
      missing="${missing} ${container}"
    fi
  done

  if [ -z "${missing}" ]; then
    echo "OK: all required reset containers are running."
    return 0
  fi

  echo "INFO: stopped required container(s):${missing}"
  if ! is_yes "${AUTO_START_REQUIRED_CONTAINERS}"; then
    echo "ERROR: automatic container startup is disabled." >&2
    echo "ERROR: set AUTO_START_REQUIRED_CONTAINERS=Y or start the containers, then retry." >&2
    exit 1
  fi

  PHASE="starting required reset containers"

  echo "==> Start only the stopped containers required by this reset"
  for container in ${missing}; do
    docker start "${container}" >/dev/null
    echo "OK: start requested for ${container}."
  done

  for container in \
      "${OGGHUB_CONTAINER}" \
      "${OGGBD_CONTAINER}" \
      "${SOURCE_DB_CONTAINER}" \
      "${BIGDATA_CONTAINER}"; do
    deadline="$(( $(date '+%s') + REQUIRED_CONTAINER_WAIT_SECONDS ))"
    while :; do
      running="$(docker inspect -f '{{.State.Running}}' "${container}" 2>/dev/null || true)"
      health="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "${container}" 2>/dev/null || true)"
      if [ "${running}" = "true" ] && { [ "${health}" = "none" ] || [ "${health}" = "healthy" ]; }; then
        echo "OK: ${container} is running (health: ${health})."
        break
      fi
      if [ "$(date '+%s')" -ge "${deadline}" ]; then
        echo "ERROR: required container is not ready: ${container} (running=${running:-unknown}, health=${health:-unknown})" >&2
        exit 1
      fi
      sleep 3
    done
  done

  echo "OK: all required reset containers are running."
}

kafka_request_succeeds() {
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc '
    timeout 15 /usr/local/kafka/bin/kafka-topics.sh \
      --bootstrap-server localhost:9092 \
      --list >/dev/null 2>&1
  '
}

ensure_bigdata_services_ready() {
  if kafka_request_succeeds; then
    echo "OK: ${BIGDATA_CONTAINER} Kafka broker is ready."
    return 0
  fi

  PHASE="starting Kafka in ${BIGDATA_CONTAINER}"
  echo "INFO: ${BIGDATA_CONTAINER} is running, but Kafka is not ready."

  if [ -f "${BIGDATA_INIT_SCRIPT}" ]; then
    echo "==> Initialize ZooKeeper and Kafka in ${BIGDATA_CONTAINER}"
    if ! BIGDATA_CONTAINER="${BIGDATA_CONTAINER}" bash "${BIGDATA_INIT_SCRIPT}"; then
      echo "WARN: Big Data initialization helper returned an error; continue with readiness recovery." >&2
    fi
  else
    echo "WARN: Big Data initialization helper not found: ${BIGDATA_INIT_SCRIPT}" >&2
  fi

  # The container may use systemd or a direct Java process depending on how it
  # was originally built. These commands are harmless when the services are
  # already running and provide a fallback if the helper stopped early.
  docker exec -u root "${BIGDATA_CONTAINER}" bash -lc '
    systemctl reset-failed zookeeper kafka >/dev/null 2>&1 || true
    systemctl start zookeeper >/dev/null 2>&1 || true
    systemctl start kafka >/dev/null 2>&1 || true
  ' || true

  deadline="$(( $(date '+%s') + KAFKA_READY_WAIT_SECONDS ))"
  while :; do
    if kafka_request_succeeds; then
      echo "OK: ${BIGDATA_CONTAINER} Kafka broker accepts topic requests."
      return 0
    fi

    if [ "$(date '+%s')" -ge "${deadline}" ]; then
      echo "ERROR: Kafka did not become ready within ${KAFKA_READY_WAIT_SECONDS} seconds." >&2
      echo "ERROR: recent Kafka log follows." >&2
      docker exec -u root "${BIGDATA_CONTAINER}" bash -lc '
        tail -80 /usr/local/kafka/logs/server.log 2>/dev/null ||
        tail -80 /usr/local/kafka/logs/kafka-startup.out 2>/dev/null || true
      ' >&2 || true
      exit 1
    fi

    sleep 3
  done
}

START_EPOCH="$(date +%s)"
START_TIME="$(date '+%Y-%m-%d %H:%M:%S')"
HOST_NAME="$(uname -n 2>/dev/null || hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo unknown)"
CURRENT_DIR="$(pwd)"

case "${RESET_ORACLE_TARGET}" in
  AUTO|auto)
    if container_is_running "${TARGET_DB_CONTAINER}"; then
      ORACLE_TARGET_ACTIVE="Y"
    else
      ORACLE_TARGET_ACTIVE="N"
    fi
    ;;
  1|Y|y|YES|yes|TRUE|true|ON|on)
    ORACLE_TARGET_ACTIVE="Y"
    ;;
  *)
    ORACLE_TARGET_ACTIVE="N"
    ;;
esac

if is_yes "${ORACLE_TARGET_ACTIVE}"; then
  TARGET_RESET_SUMMARY="enabled; ${TARGET_DB_CONTAINER} is already running"
  RESET_PROCESS_SUMMARY="${EXTRACT_NAME}, ${ORACLE_REPLICAT_NAME}, ${DISTPATH_NAME}, ${KAFKA_REPLICAT_NAME}"
  RESET_OBJECT_SUMMARY="Source and Target"
else
  TARGET_RESET_SUMMARY="skipped; the Target DB is not required for the OSA/Kafka path"
  RESET_PROCESS_SUMMARY="${EXTRACT_NAME}, ${DISTPATH_NAME}, ${KAFKA_REPLICAT_NAME}"
  RESET_OBJECT_SUMMARY="Source"
fi

cat <<SUMMARY
Reset GoldenGate lab environment
Start time          : ${START_TIME}
Host name           : ${HOST_NAME}
Working directory  : ${CURRENT_DIR}
OGGHUB container   : ${OGGHUB_CONTAINER}
OGGBD container    : ${OGGBD_CONTAINER}
Source DB container: ${SOURCE_DB_CONTAINER}
Oracle Target reset: ${TARGET_RESET_SUMMARY}
Kafka container    : ${BIGDATA_CONTAINER}

This will stop/delete ${RESET_PROCESS_SUMMARY},
remove ${SOURCE_TRAIL}*/${TARGET_TRAIL}* trail files, reset OSA sample
objects in ${RESET_OBJECT_SUMMARY}, reset OSA Kafka topics, then recreate and start the
OGG path. It does not create OSA sample objects unless --create-objects is used.

INFO: This reset usually takes a few minutes.
INFO: Some steps can look idle while Docker, Admin Client, database, or Kafka
INFO: commands are running. Please wait and do not type additional input unless
INFO: this script prompts you.
INFO: Stopped required containers are started automatically after confirmation.
SUMMARY

# Missing containers indicate an incomplete installation. Stopped containers are
# a normal reader state and are recovered after reset confirmation.
check_container_exists "${OGGHUB_CONTAINER}"
check_container_exists "${OGGBD_CONTAINER}"
check_container_exists "${SOURCE_DB_CONTAINER}"
check_container_exists "${BIGDATA_CONTAINER}"
if is_yes "${ORACLE_TARGET_ACTIVE}"; then
  check_container_exists "${TARGET_DB_CONTAINER}"
fi

if ! is_yes "${YES}" && ! is_yes "${CONTAINER_PREPARE_ONLY}"; then
  echo 'This reset deletes and recreates OGG processes, paths, trails, sample objects, and Kafka topics.'
  printf 'Press Enter for RESET, or type NO to cancel [RESET]: '
  read -r answer
  answer="${answer:-RESET}"
  if [ "${answer}" != "RESET" ] && [ "${answer}" != "Y" ] && [ "${answer}" != "YES" ] && [ "${answer}" != "y" ] && [ "${answer}" != "yes" ]; then
    echo "Canceled."
    exit 1
  fi
fi

if ! is_yes "${CONTAINER_PREPARE_ONLY}" && [ -z "${OGG_PASS}" ]; then
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

ensure_required_containers_running
ensure_bigdata_services_ready

PHASE="sync canonical OSA scripts to Source DB"
sync_source_osa_scripts

if is_yes "${CONTAINER_PREPARE_ONLY}"; then
  echo "OK: container preparation check completed; reset work was not started."
  exit 0
fi

PHASE="verify reset prerequisites"
verify_reset_prerequisites

echo
echo "==> Stop OGGHUB processes"
PHASE="stop OGGHUB processes"
RESET_WORK_STARTED="Y"
run_admin_ignore "${OGGHUB_CONTAINER}" \
  "stop ${EXTRACT_NAME}!" \
  "stop distpath ${DISTPATH_NAME}!" \
  "info all" \
  "info distpath all"

if is_yes "${ORACLE_TARGET_ACTIVE}"; then
  run_admin_ignore "${OGGHUB_CONTAINER}" \
    "stop ${ORACLE_REPLICAT_NAME}!" \
    "info all"
fi

echo
echo "==> Stop OGGBD Replicat"
PHASE="stop OGGBD Replicat"
run_admin_ignore "${OGGBD_CONTAINER}" \
  "stop ${KAFKA_REPLICAT_NAME}!" \
  "info all"

echo
echo "==> Stop stale Chapter 20 OGGHUB processes"
PHASE="stop stale Chapter 20 OGGHUB processes"
for group_name in ${STALE_OGGHUB_REPLICATS}; do
  if ogg_group_exists "${OGGHUB_CONTAINER}" "${group_name}"; then
    run_admin_ignore "${OGGHUB_CONTAINER}" "stop ${group_name}!"
  else
    echo "SKIP: stale Replicat ${group_name} does not exist."
  fi
done
if ! is_yes "${ORACLE_TARGET_ACTIVE}"; then
  echo "INFO: Target DB is stopped; stale Chapter 20 checkpoint-table rows are cleared by the Chapter 20 setup before lanes are recreated."
fi
for group_name in ${STALE_OGGHUB_EXTRACTS}; do
  if ogg_group_exists "${OGGHUB_CONTAINER}" "${group_name}"; then
    run_admin_ignore "${OGGHUB_CONTAINER}" "stop ${group_name}!"
  else
    echo "SKIP: stale Extract ${group_name} does not exist."
  fi
done

wait_for_no_ogg_group_process "${OGGHUB_CONTAINER}" "${EXTRACT_NAME}" "${PROCESS_WAIT_SECONDS}"
if is_yes "${ORACLE_TARGET_ACTIVE}"; then
  wait_for_no_ogg_group_process "${OGGHUB_CONTAINER}" "${ORACLE_REPLICAT_NAME}" "${PROCESS_WAIT_SECONDS}"
fi
wait_for_no_ogg_group_process "${OGGBD_CONTAINER}" "${KAFKA_REPLICAT_NAME}" "${PROCESS_WAIT_SECONDS}"
wait_for_distpath_not_running "${OGGHUB_CONTAINER}" "${DISTPATH_NAME}" "${PROCESS_WAIT_SECONDS}"
for group_name in ${STALE_OGGHUB_REPLICATS} ${STALE_OGGHUB_EXTRACTS}; do
  wait_for_no_ogg_group_process "${OGGHUB_CONTAINER}" "${group_name}" "${PROCESS_WAIT_SECONDS}"
done

echo
echo "==> Delete OGGHUB Extract"
PHASE="delete OGGHUB Extract"
run_admin_ignore "${OGGHUB_CONTAINER}" \
  "dblogin useridalias ${SOURCE_DB_ALIAS} domain ${DOMAIN}" \
  "delete extract ${EXTRACT_NAME}!" \
  "info all"

if is_yes "${ORACLE_TARGET_ACTIVE}"; then
  echo
  echo "==> Delete OGGHUB Oracle Replicat"
  PHASE="delete OGGHUB Oracle Replicat"
  run_admin_ignore "${OGGHUB_CONTAINER}" \
    "dblogin useridalias ${TARGET_DB_ALIAS} domain ${DOMAIN}" \
    "delete replicat ${ORACLE_REPLICAT_NAME}" \
    "info all"
else
  echo "INFO: Skip ${ORACLE_REPLICAT_NAME}; ${TARGET_DB_CONTAINER} is not used by this OSA/Kafka reset."
fi

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

echo
echo "==> Delete stale Chapter 20 OGGHUB processes"
PHASE="delete stale Chapter 20 OGGHUB processes"
for group_name in ${STALE_OGGHUB_REPLICATS}; do
  if ogg_group_exists "${OGGHUB_CONTAINER}" "${group_name}"; then
    if is_yes "${ORACLE_TARGET_ACTIVE}"; then
      run_admin_ignore "${OGGHUB_CONTAINER}" \
        "dblogin useridalias ${TARGET_DB_ALIAS} domain ${DOMAIN}" \
        "delete replicat ${group_name}!"
    else
      run_admin_ignore "${OGGHUB_CONTAINER}" "delete replicat ${group_name}!"
    fi
  else
    echo "SKIP: stale Replicat ${group_name} is already absent."
  fi
done
for group_name in ${STALE_OGGHUB_EXTRACTS}; do
  if ogg_group_exists "${OGGHUB_CONTAINER}" "${group_name}"; then
    run_admin_ignore "${OGGHUB_CONTAINER}" \
      "dblogin useridalias ${SOURCE_DB_ALIAS} domain ${DOMAIN}" \
      "delete extract ${group_name}!"
  else
    echo "SKIP: stale Extract ${group_name} is already absent."
  fi
done

verify_ogg_group_absent "${OGGHUB_CONTAINER}" "${EXTRACT_NAME}"
if is_yes "${ORACLE_TARGET_ACTIVE}"; then
  verify_ogg_group_absent "${OGGHUB_CONTAINER}" "${ORACLE_REPLICAT_NAME}"
fi
verify_distpath_absent "${OGGHUB_CONTAINER}" "${DISTPATH_NAME}"
verify_ogg_group_absent "${OGGBD_CONTAINER}" "${KAFKA_REPLICAT_NAME}"
for group_name in ${STALE_OGGHUB_REPLICATS} ${STALE_OGGHUB_EXTRACTS}; do
  verify_ogg_group_absent "${OGGHUB_CONTAINER}" "${group_name}"
done

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
echo "==> Remove stale Chapter 20 OGGHUB trails"
PHASE="remove stale Chapter 20 OGGHUB trails"
for trail_name in ${STALE_OGGHUB_TRAILS}; do
  run_in_container "${OGGHUB_CONTAINER}" bash -lc "
    set -euo pipefail
    cd /u02/Deployment/var/lib
    shopt -s nullglob
    files=(data/${trail_name}*)
    if [ \${#files[@]} -gt 0 ]; then
      rm -f \"\${files[@]}\"
      echo 'OK: removed stale ${trail_name} trail files.'
    else
      echo 'SKIP: no stale ${trail_name} trail files were found.'
    fi
  "
done

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
echo "==> Reset OSA sample objects in ${RESET_OBJECT_SUMMARY}"
PHASE="reset OSA sample objects"
stop_osa_generators "${SOURCE_DB_CONTAINER}"
kill_osa_sqlplus_sessions "${SOURCE_DB_CONTAINER}"
run_script_as_oracle "${SOURCE_DB_CONTAINER}" reset_osa_objects.sh
remove_source_legacy_ai_objects
if is_yes "${ORACLE_TARGET_ACTIVE}"; then
  stop_osa_generators "${TARGET_DB_CONTAINER}"
  kill_osa_sqlplus_sessions "${TARGET_DB_CONTAINER}"
  run_script_as_oracle "${TARGET_DB_CONTAINER}" reset_osa_objects.sh
  ensure_target_ogg_identity_ddl_privilege
fi

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

if is_yes "${ORACLE_TARGET_ACTIVE}"; then
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
fi

echo
echo "==> Ensure OGGHUB Big Data credential alias"
PHASE="ensure OGGHUB Big Data credential alias"
credential_output="$(run_admin "${OGGHUB_CONTAINER}" "info credentialstore")"
printf '%s\n' "${credential_output}"
if ! printf '%s\n' "${credential_output}" | grep -q 'Alias: oggbd_admin'; then
  run_admin "${OGGHUB_CONTAINER}" \
    "alter credentialstore add user ${OGG_USER} password ${OGG_PASS} alias oggbd_admin domain ${DOMAIN}"
else
  echo "SKIP: oggbd_admin credential alias already exists."
fi

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
if is_yes "${ORACLE_TARGET_ACTIVE}"; then
  verify_ogg_group_running "${OGGHUB_CONTAINER}" "${ORACLE_REPLICAT_NAME}"
fi
verify_distpath_running "${OGGHUB_CONTAINER}" "${DISTPATH_NAME}"
verify_ogg_group_running "${OGGBD_CONTAINER}" "${KAFKA_REPLICAT_NAME}"

if is_yes "${CREATE_OBJECTS}"; then
  echo
  echo "==> Create OSA sample objects from Source DB"
  PHASE="create OSA sample objects from Source DB"
  run_script_as_oracle "${SOURCE_DB_CONTAINER}" prepare_osa_source_objects.sh

  echo
    echo "==> Seed 26ai churn business events in Source SOE"
    PHASE="seed 26ai churn business events in Source SOE"
  run_script_as_oracle "${SOURCE_DB_CONTAINER}" prepare_ai_26ai_demo.sh

  echo
  PHASE="emit live GoldenGate delivery probe"
  emit_kafka_flow_probe

  echo
  PHASE="verify live GoldenGate delivery to Kafka"
  wait_for_kafka_source_data

  if is_yes "${ORACLE_TARGET_ACTIVE}"; then
    echo
    PHASE="grant APEX access to replicated target objects"
    wait_for_target_osa_objects "${TARGET_OBJECT_WAIT_SECONDS}"
    grant_target_apex_source_privileges
  fi

  echo
  echo "==> Verify OGGHUB Extract statistics"
  PHASE="verify OGGHUB Extract statistics"
  run_stats_with_retry "${OGGHUB_CONTAINER}" \
    "stats extract ${EXTRACT_NAME} totalsonly soe.*" \
    "Extract ${EXTRACT_NAME}"
  if is_yes "${ORACLE_TARGET_ACTIVE}"; then
    echo "==> Verify OGGHUB Oracle Replicat statistics"
    PHASE="verify OGGHUB Oracle Replicat statistics"
    run_stats_with_retry "${OGGHUB_CONTAINER}" \
      "stats replicat ${ORACLE_REPLICAT_NAME} totalsonly soe.*" \
      "Replicat ${ORACLE_REPLICAT_NAME}"
  fi

  echo
  echo "==> Verify OGGBD Replicat statistics"
  PHASE="verify OGGBD Replicat statistics"
  run_stats_with_retry "${OGGBD_CONTAINER}" \
    "stats replicat ${KAFKA_REPLICAT_NAME} totalsonly soe.*" \
    "Replicat ${KAFKA_REPLICAT_NAME}"
else
  echo
  echo "INFO: OSA sample object creation is intentionally skipped."
  echo "INFO: Run prepare_osa_source_objects.sh manually in the next lab step."
fi

END_EPOCH="$(date +%s)"
END_TIME="$(date '+%Y-%m-%d %H:%M:%S')"
ELAPSED="$((END_EPOCH - START_EPOCH))"

echo
echo "End time: ${END_TIME}"
echo "Elapsed time: ${ELAPSED} seconds"
echo "GoldenGate lab environment reset completed."
