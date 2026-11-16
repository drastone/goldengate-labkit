#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ] || shopt -qo posix 2>/dev/null; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  fi
  echo "ERROR: lab05_init.sh requires bash." >&2
  exit 1
fi

set -Eeuo pipefail

LAB05_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_HOME="${LAB_HOME:-$(cd "${LAB05_DIR}/../.." && pwd)}"
SOURCE_CONTAINER="${SOURCE_CONTAINER:-demo_osrc_23ai}"
TARGET_CONTAINER="${TARGET_CONTAINER:-demo_otrg_23ai}"
ORACLE_SID="${ORACLE_SID:-ORCLCDB}"
VERIFY_SCRIPT="${VERIFY_SCRIPT:-${LAB05_DIR}/check_lab05.sh}"
LOG_DIR="${LAB05_LOG_DIR:-${LAB_HOME}/logs/lab05}"
LOG_FILE="${LAB05_LOG_FILE:-${LOG_DIR}/$(date '+%Y%m%d-%H%M%S')-lab05-init.log}"
STARTED_AT="$(date +%s)"

mkdir -p "${LOG_DIR}"
if [ "${LAB05_LOG_ACTIVE:-N}" != "Y" ]; then
  export LAB05_LOG_ACTIVE=Y LAB05_LOG_FILE="${LOG_FILE}"
  set +e
  bash "$0" "$@" 2>&1 | tee -a "${LOG_FILE}"
  rc=${PIPESTATUS[0]}
  exit "${rc}"
fi

elapsed() {
  local seconds
  seconds=$(( $(date +%s) - STARTED_AT ))
  printf '%02d:%02d:%02d' $((seconds / 3600)) $(((seconds % 3600) / 60)) $((seconds % 60))
}

fail() {
  local rc="$?"
  trap - ERR
  echo "ERROR: Chapter 5 initialization failed with exit code ${rc}." >&2
  echo "ERROR: review log: ${LOG_FILE}" >&2
  exit "${rc}"
}
trap fail ERR

require_running_container() {
  local container="$1"
  local label="$2"

  if [ "$(docker inspect -f '{{.State.Running}}' "${container}" 2>/dev/null || true)" != "true" ]; then
    echo "ERROR: ${label} container is not running: ${container}" >&2
    echo "ERROR: run ${LAB_HOME}/startDocker.sh before Chapter 5 initialization." >&2
    return 1
  fi
}

run_sql() {
  local container="$1"
  docker exec -i -u oracle "${container}" bash -lc \
    "export ORACLE_SID='${ORACLE_SID}'; sqlplus -s / as sysdba"
}

query_scalar() {
  local container="$1"
  local query="$2"

  run_sql "${container}" <<SQL | awk 'NF { value=$0 } END { gsub(/^[[:space:]]+|[[:space:]]+$/, "", value); print value }'
set pages 0 feedback off heading off verify off echo off trimspool on
whenever sqlerror exit sql.sqlcode
${query};
exit
SQL
}

configure_common_pdb() {
  local container="$1"
  local replication_role="$2"

  run_sql "${container}" <<SQL
set serveroutput on feedback off verify off
whenever sqlerror exit sql.sqlcode

alter session set container=ORCLPDB1;
alter profile default limit password_life_time unlimited;

declare
  l_count number;
begin
  select count(*) into l_count from dba_tablespaces where tablespace_name = 'SOE';
  if l_count = 0 then
    execute immediate 'create tablespace SOE datafile size 1G autoextend on next 100M maxsize 5G';
  end if;

  select count(*) into l_count from dba_users where username = 'SOE';
  if l_count = 0 then
    execute immediate 'create user soe identified by soe default tablespace SOE temporary tablespace TEMP profile default account unlock';
  else
    execute immediate 'alter user soe identified by soe default tablespace SOE temporary tablespace TEMP profile default account unlock';
  end if;

  select count(*) into l_count from dba_tablespaces where tablespace_name = 'OGG';
  if l_count = 0 then
    execute immediate 'create tablespace OGG datafile size 100M autoextend on next 50M maxsize 1G extent management local uniform size 1M segment space management auto';
  end if;

  select count(*) into l_count from dba_users where username = 'OGG';
  if l_count = 0 then
    execute immediate 'create user ogg identified by ogg default tablespace OGG temporary tablespace TEMP profile default account unlock';
  else
    execute immediate 'alter user ogg identified by ogg default tablespace OGG temporary tablespace TEMP profile default account unlock';
  end if;
end;
/

grant CONNECT, RESOURCE, CREATE VIEW, ALTER SESSION,
      CREATE DATABASE LINK, ANALYZE ANY DICTIONARY, ANALYZE ANY,
      CREATE JOB, MANAGE SCHEDULER, MANAGE ANY QUEUE to SOE;
grant EXECUTE ON dbms_lock to SOE;
grant SELECT ON v_\$database to SOE;
alter user soe quota unlimited on SOE;

alter user ogg quota unlimited on OGG;
grant CONNECT, RESOURCE to ogg;
grant ${replication_role} to ogg;
exit
SQL
}

command -v docker >/dev/null 2>&1 || {
  echo "ERROR: required command not found: docker" >&2
  exit 1
}
require_running_container "${SOURCE_CONTAINER}" "Source DB"
require_running_container "${TARGET_CONTAINER}" "Target DB"

echo "==> START: Chapter 5 Source/Target database initialization"
echo "INFO: Source DB: ${SOURCE_CONTAINER}"
echo "INFO: Target DB: ${TARGET_CONTAINER}"
echo "INFO: This script is idempotent and may be run again."

echo "==> Configure Source CDB for GoldenGate capture"
run_sql "${SOURCE_CONTAINER}" <<'SQL'
set feedback off verify off
whenever sqlerror exit sql.sqlcode
alter session set container=CDB$ROOT;
alter system set enable_goldengate_replication=true scope=both;
declare
  l_enabled varchar2(8);
begin
  select supplemental_log_data_min into l_enabled from v$database;
  if l_enabled <> 'YES' then
    execute immediate 'alter database add supplemental log data';
  end if;
end;
/
exit
SQL

SOURCE_LOG_MODE="$(query_scalar "${SOURCE_CONTAINER}" "select log_mode from v\$database")"
if [ "${SOURCE_LOG_MODE}" = "ARCHIVELOG" ]; then
  echo "SKIP: Source database is already in ARCHIVELOG mode."
  run_sql "${SOURCE_CONTAINER}" <<'SQL'
set feedback off verify off
whenever sqlerror exit sql.sqlcode
begin
  execute immediate 'alter pluggable database all open';
exception
  when others then
    if sqlcode <> -65019 then
      raise;
    end if;
end;
/
alter pluggable database all save state;
exit
SQL
else
  echo "==> Restart Source DB and enable ARCHIVELOG mode"
  run_sql "${SOURCE_CONTAINER}" <<'SQL'
set feedback off verify off
whenever sqlerror exit sql.sqlcode
shutdown immediate;
startup mount;
alter database archivelog;
alter database open;
alter pluggable database all open;
alter pluggable database all save state;
exit
SQL
fi

echo "==> Configure Source PDB users, tablespaces, and capture role"
configure_common_pdb "${SOURCE_CONTAINER}" "OGG_CAPTURE"

echo "==> Configure Target CDB for GoldenGate apply"
run_sql "${TARGET_CONTAINER}" <<'SQL'
set feedback off verify off
whenever sqlerror exit sql.sqlcode
alter session set container=CDB$ROOT;
alter system set enable_goldengate_replication=true scope=both;
begin
  execute immediate 'alter pluggable database all open';
exception
  when others then
    if sqlcode <> -65019 then
      raise;
    end if;
end;
/
alter pluggable database all save state;
exit
SQL

echo "==> Configure Target PDB users, tablespaces, and apply role"
configure_common_pdb "${TARGET_CONTAINER}" "OGG_APPLY"
run_sql "${TARGET_CONTAINER}" <<'SQL'
set feedback off verify off
whenever sqlerror exit sql.sqlcode
alter session set container=ORCLPDB1;
grant CREATE ANY TABLE, ALTER ANY TABLE, DROP ANY TABLE,
      COMMENT ANY TABLE, CREATE ANY INDEX, ALTER ANY INDEX,
      DROP ANY INDEX, CREATE ANY SEQUENCE, DROP ANY SEQUENCE,
      SELECT ANY SEQUENCE to ogg;
grant SELECT ANY TABLE, INSERT ANY TABLE, UPDATE ANY TABLE,
      DELETE ANY TABLE to ogg;
exit
SQL

echo "==> Verify Chapter 5 database prerequisites"
bash "${VERIFY_SCRIPT}"

trap - ERR
echo "OK: Chapter 5 Source/Target database initialization completed."
echo "OK: elapsed time: $(elapsed)"
echo "OK: log file: ${LOG_FILE}"
