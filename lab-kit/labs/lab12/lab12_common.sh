#!/usr/bin/env bash

set -Eeuo pipefail

LAB12_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_HOME="${LAB_HOME:-$(cd "${LAB12_DIR}/../.." && pwd)}"
LAB12_LOG_DIR="${LAB12_LOG_DIR:-${LAB_HOME}/logs/lab12}"
TARGET_DB_CONTAINER="${TARGET_DB_CONTAINER:-demo_otrg_23ai}"
TARGET_PDB="${TARGET_PDB:-ORCLPDB1}"
LAB_PASSWORD="${LAB_PASSWORD:-WElcome1234##}"
ORDS_JAVA_HOME="${ORDS_JAVA_HOME:-}"
APEX_INSTALL_ROOT="${APEX_INSTALL_ROOT:-/home/oracle/apex_install}"
APEX_HOME="${APEX_HOME:-${APEX_INSTALL_ROOT}/apex}"
APEX_STATIC_PATH="${APEX_STATIC_PATH:-${APEX_HOME}/images}"

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
  local java_output
  local java_version

  if [ -z "${ORDS_JAVA_HOME}" ]; then
    ORDS_JAVA_HOME="$(lab12_find_ords_java_home || true)"
  fi

  if [ -z "${ORDS_JAVA_HOME}" ] || ! docker exec "${TARGET_DB_CONTAINER}" test -x "${ORDS_JAVA_HOME}/bin/java"; then
    lab12_log "ERROR: Java 17 or later was not found in ${TARGET_DB_CONTAINER}."
    return 1
  fi

  java_output="$(docker exec "${TARGET_DB_CONTAINER}" "${ORDS_JAVA_HOME}/bin/java" -version 2>&1)"
  java_version="${java_output%%$'\n'*}"
  export ORDS_JAVA_HOME
  lab12_log "OK: ORDS JAVA_HOME: ${ORDS_JAVA_HOME}"
  lab12_log "OK: ORDS Java runtime: ${java_version}"
}

lab12_find_ords_java_home() {
  docker exec "${TARGET_DB_CONTAINER}" sh -lc '
java_major_version() {
  "$1/bin/java" -version 2>&1 | awk -F '\''[ ".]+'\'' '\''/version/ { print $3; exit }'\''
}

for candidate in "${JAVA_HOME:-}" /usr/java/default /usr/java/latest /usr/java/jdk-* /usr/lib/jvm/jdk-* /usr/lib/jvm/java-*; do
  [ -n "${candidate}" ] && [ -x "${candidate}/bin/java" ] || continue
  major="$(java_major_version "${candidate}")"
  if [ -n "${major}" ] && [ "${major}" -ge 17 ]; then
    readlink -f "${candidate}"
    exit 0
  fi
done
exit 1
'
}

lab12_find_apex_static_path() {
  docker exec "${TARGET_DB_CONTAINER}" sh -lc "
for candidate in '${APEX_STATIC_PATH}' /home/oracle/apex/images /home/oracle/ords_images/i; do
  if [ -f \"\${candidate}/apex_version.txt\" ]; then
    printf '%s\\n' \"\${candidate}\"
    exit 0
  fi
done
exit 1
"
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

lab12_apex_workspace_count() {
  local workspace_name="${1:-OGG}"

  docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba <<'SQL'
set pages 0 feedback off heading off verify off echo off trimspool on
whenever sqlerror exit failure
alter session set container=${TARGET_PDB};
select 'APEX_WORKSPACES=' || count(*)
from apex_workspaces
where upper(workspace) = upper('${workspace_name}');
exit
SQL" | sed -n 's/^[[:space:]]*APEX_WORKSPACES=//p' | tail -1
}

lab12_apex_workspace_user_state() {
  local workspace_name="${1:-OGG}"
  local user_name="${2:-GGADMIN}"

  docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba <<'SQL'
set pages 0 feedback off heading off verify off echo off trimspool on
whenever sqlerror exit failure
alter session set container=${TARGET_PDB};
select 'APEX_WORKSPACE_USER=' || workspace_name || '|' || user_name || '|' ||
       is_admin || '|' || is_application_developer || '|' || account_locked
from apex_workspace_apex_users
where upper(workspace_name) = upper('${workspace_name}')
  and upper(user_name) = upper('${user_name}');
exit
SQL" | sed -n 's/^[[:space:]]*APEX_WORKSPACE_USER=//p' | tail -1
}
