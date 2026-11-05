#!/usr/bin/env bash

set -Eeuo pipefail

LAB12_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_HOME="${LAB_HOME:-$(cd "${LAB12_DIR}/../.." && pwd)}"
LAB12_LOG_DIR="${LAB12_LOG_DIR:-${LAB_HOME}/logs/lab12}"
TARGET_DB_CONTAINER="${TARGET_DB_CONTAINER:-demo_otrg_23ai}"
TARGET_PDB="${TARGET_PDB:-ORCLPDB1}"
LAB_PASSWORD="${LAB_PASSWORD:-WElcome1234##}"
ORDS_JAVA_HOME="${ORDS_JAVA_HOME:-/usr/java/jdk-17}"

LAB12_STAGE=""
LAB12_LOG_FILE=""
LAB12_STAGE_START=0

lab12_timestamp() {
  date '+%Y%m%d-%H%M%S'
}

lab12_elapsed() {
  local started="$1"
  local ended
  local elapsed

  ended="$(date +%s)"
  elapsed=$((ended - started))
  printf '%02d:%02d:%02d' $((elapsed / 3600)) $(((elapsed % 3600) / 60)) $((elapsed % 60))
}

lab12_log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

lab12_begin_stage() {
  LAB12_STAGE="$1"
  mkdir -p "${LAB12_LOG_DIR}"
  LAB12_LOG_FILE="${LAB12_LOG_FILE:-${LAB12_LOG_DIR}/$(lab12_timestamp)-${LAB12_STAGE}.log}"
  LAB12_STAGE_START="$(date +%s)"
  exec > >(tee -a "${LAB12_LOG_FILE}") 2>&1
  trap 'lab12_fail_stage $?' ERR

  lab12_log "==> START: ${LAB12_STAGE}"
  lab12_log "INFO: log file: ${LAB12_LOG_FILE}"
}

lab12_fail_stage() {
  local rc="$1"
  trap - ERR
  lab12_log "ERROR: ${LAB12_STAGE} failed with exit code ${rc}."
  lab12_log "ERROR: elapsed time: $(lab12_elapsed "${LAB12_STAGE_START}")"
  lab12_log "ERROR: review log: ${LAB12_LOG_FILE}"
  exit "${rc}"
}

lab12_finish_stage() {
  trap - ERR
  lab12_log "OK: ${LAB12_STAGE} completed."
  lab12_log "OK: elapsed time: $(lab12_elapsed "${LAB12_STAGE_START}")"
  lab12_log "OK: log file: ${LAB12_LOG_FILE}"
}

lab12_require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    lab12_log "ERROR: required command not found: $1"
    return 1
  }
}

lab12_require_running_container() {
  if ! docker ps --format '{{.Names}}' | grep -qx "${TARGET_DB_CONTAINER}"; then
    lab12_log "ERROR: target DB container is not running: ${TARGET_DB_CONTAINER}"
    lab12_log "ERROR: run /home/oracle/startDocker.sh before Chapter 12 setup."
    return 1
  fi
}

lab12_require_ords_java() {
  local java_version

  if ! docker exec "${TARGET_DB_CONTAINER}" test -x "${ORDS_JAVA_HOME}/bin/java"; then
    lab12_log "ERROR: Java 17 or later was not found: ${ORDS_JAVA_HOME}/bin/java"
    return 1
  fi

  java_version="$(docker exec "${TARGET_DB_CONTAINER}" "${ORDS_JAVA_HOME}/bin/java" -version 2>&1 | head -1)"
  lab12_log "OK: ORDS Java runtime: ${java_version}"
}

lab12_apex_registry_state() {
  docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba <<'SQL'
set pages 0 feedback off heading off verify off echo off trimspool on
whenever sqlerror exit failure
alter session set container=${TARGET_PDB};
select 'APEX_STATE=' || version || '|' || status
from dba_registry
where comp_id = 'APEX';
exit
SQL" | sed -n 's/^[[:space:]]*APEX_STATE=//p' | tail -1
}

lab12_apex_user_count() {
  docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba <<'SQL'
set pages 0 feedback off heading off verify off echo off trimspool on
whenever sqlerror exit failure
alter session set container=${TARGET_PDB};
select 'APEX_USERS=' || count(*)
from dba_users
where username like 'APEX\\_%' escape '\\'
   or username = 'FLOWS_FILES';
exit
SQL" | sed -n 's/^[[:space:]]*APEX_USERS=//p' | tail -1
}

lab12_ords_user_count() {
  docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba <<'SQL'
set pages 0 feedback off heading off verify off echo off trimspool on
whenever sqlerror exit failure
alter session set container=${TARGET_PDB};
select 'ORDS_USERS=' || count(*)
from dba_users
where username in ('ORDS_METADATA', 'ORDS_PUBLIC_USER');
exit
SQL" | sed -n 's/^[[:space:]]*ORDS_USERS=//p' | tail -1
}
