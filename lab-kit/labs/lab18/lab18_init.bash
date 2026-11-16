#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ] || shopt -qo posix 2>/dev/null; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  fi
  echo "ERROR: lab18_init.sh requires bash." >&2
  exit 1
fi

set -Eeuo pipefail

LAB18_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${APP_DIR:-${LAB18_DIR}/apps}"
TARGET_DB_CONTAINER="${TARGET_DB_CONTAINER:-demo_otrg_23ai}"
TARGET_PDB="${TARGET_PDB:-ORCLPDB1}"
APEX_WORKSPACE_NAME="${APEX_WORKSPACE_NAME:-OGG}"
APEX_SCHEMA="${APEX_SCHEMA:-GGADMIN}"
HOST_ORDS_PORT="${HOST_ORDS_PORT:-36080}"
CONTAINER_APP_DIR="/home/oracle/labs/lab18/apps"
LOG_DIR="${LOG_DIR:-$(cd "${LAB18_DIR}/../.." && pwd)/logs/lab18}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/$(date '+%Y%m%d-%H%M%S')-lab18-init.log}"
THEME_SOURCE_APP_ID="${THEME_SOURCE_APP_ID:-102}"
APP_IDS=(300 310 320 330 340 350 360 370 380 390 400)

STARTED_AT="$(date +%s)"
mkdir -p "${LOG_DIR}"
exec > >(tee -a "${LOG_FILE}") 2>&1

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

elapsed() {
  local seconds=$(( $(date +%s) - STARTED_AT ))
  printf '%02d:%02d:%02d' $((seconds / 3600)) $(((seconds % 3600) / 60)) $((seconds % 60))
}

fail() {
  log "ERROR: $*"
  log "ERROR: review log: ${LOG_FILE}"
  exit 1
}

on_error() {
  local rc="$1"
  trap - ERR
  log "ERROR: lab18_init.sh failed with exit code ${rc}."
  log "ERROR: elapsed time: $(elapsed)"
  log "ERROR: review log: ${LOG_FILE}"
  exit "${rc}"
}
trap 'on_error $?' ERR

sql_sys() {
  docker exec -i -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba" <<SQL
whenever sqlerror exit failure rollback
set pages 0 feedback off heading off verify off echo off trimspool on
alter session set container=${TARGET_PDB};
$1
exit
SQL
}

application_count() {
  local app_id="$1"

  sql_sys "select 'APP_COUNT=' || count(*) from apex_applications where workspace = upper('${APEX_WORKSPACE_NAME}') and application_id = ${app_id};" |
    sed -n 's/^[[:space:]]*APP_COUNT=//p' | tail -1
}

require_prerequisites() {
  local apex_state workspace_count theme_source_count app_id export_file

  command -v docker >/dev/null 2>&1 || fail "docker command not found."
  command -v curl >/dev/null 2>&1 || fail "curl command not found."
  command -v sha256sum >/dev/null 2>&1 || fail "sha256sum command not found."

  docker ps --format '{{.Names}}' | grep -qx "${TARGET_DB_CONTAINER}" ||
    fail "Target DB container is not running: ${TARGET_DB_CONTAINER}. Run startDocker.sh first."

  apex_state="$(sql_sys "select 'APEX_STATE=' || version || '|' || status from dba_registry where comp_id = 'APEX';" |
    sed -n 's/^[[:space:]]*APEX_STATE=//p' | tail -1)"
  case "${apex_state}" in
    *'|VALID') log "OK: APEX ${apex_state}" ;;
    '') fail "APEX is not installed in ${TARGET_PDB}. Run lab12_init.sh first." ;;
    *) fail "APEX registry state is not VALID: ${apex_state}" ;;
  esac

  workspace_count="$(sql_sys "select 'WORKSPACE_COUNT=' || count(*) from apex_workspaces where upper(workspace) = upper('${APEX_WORKSPACE_NAME}');" |
    sed -n 's/^[[:space:]]*WORKSPACE_COUNT=//p' | tail -1)"
  [ "${workspace_count:-0}" -eq 1 ] ||
    fail "APEX workspace ${APEX_WORKSPACE_NAME} is not ready. Run lab12_init.sh first."
  log "OK: APEX workspace ${APEX_WORKSPACE_NAME}"

  theme_source_count="$(application_count "${THEME_SOURCE_APP_ID}")"
  [ "${theme_source_count:-0}" -eq 1 ] ||
    fail "Theme source App ${THEME_SOURCE_APP_ID} is missing from workspace ${APEX_WORKSPACE_NAME}. Run lab12_init.sh first."
  log "OK: Theme source App ${THEME_SOURCE_APP_ID}"

  curl -fsS --max-time 10 -o /dev/null "http://127.0.0.1:${HOST_ORDS_PORT}/ords/" ||
    fail "ORDS is not responding on host port ${HOST_ORDS_PORT}."
  log "OK: ORDS is responding on host port ${HOST_ORDS_PORT}."

  [ -s "${APP_DIR}/repair_subscribed_theme.sql" ] ||
    fail "Theme repair SQL not found: ${APP_DIR}/repair_subscribed_theme.sql"

  for app_id in "${APP_IDS[@]}"; do
    export_file="${APP_DIR}/f${app_id}.sql"
    [ -s "${export_file}" ] || fail "APEX export not found: ${export_file}"
  done
}

stage_file() {
  local host_file="$1"
  local container_file="$2"
  local label="$3"
  local host_sha container_sha

  host_sha="$(sha256sum "${host_file}" | awk '{print $1}')"
  container_sha="$(docker exec "${TARGET_DB_CONTAINER}" sha256sum "${container_file}" 2>/dev/null |
    awk '{print $1}' || true)"

  if [ "${host_sha}" = "${container_sha}" ]; then
    log "SKIP: ${label} is already staged."
    return
  fi

  docker exec -u root "${TARGET_DB_CONTAINER}" mkdir -p "${CONTAINER_APP_DIR}"
  docker cp "${host_file}" "${TARGET_DB_CONTAINER}:${container_file}"
  docker exec -u root "${TARGET_DB_CONTAINER}" chown oracle:oinstall "${container_file}"
  docker exec -u root "${TARGET_DB_CONTAINER}" chmod 644 "${container_file}"
  log "OK: staged ${label}."
}

import_app() {
  local app_id="$1"
  local host_file="${APP_DIR}/f${app_id}.sql"
  local container_file="${CONTAINER_APP_DIR}/f${app_id}.sql"
  local app_offset app_count

  app_count="$(application_count "${app_id}")"
  if [ "${app_count:-0}" -eq 1 ]; then
    log "SKIP: App ${app_id} is already installed."
    return
  fi

  app_offset="$(sed -n 's/.*,p_default_id_offset=>\([0-9][0-9]*\).*/\1/p' "${host_file}" | head -1)"
  [[ "${app_offset}" =~ ^[0-9]+$ ]] || fail "App ${app_id} export has no valid p_default_id_offset."

  log "==> Import App ${app_id}"
  docker exec -i -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba" <<SQL
whenever sqlerror exit failure rollback
set define off serveroutput on
alter session set container=${TARGET_PDB};
begin
  apex_application_install.set_workspace('${APEX_WORKSPACE_NAME}');
  apex_application_install.set_schema('${APEX_SCHEMA}');
  apex_application_install.set_application_id(${app_id});
  apex_application_install.set_offset(${app_offset});
  apex_application_install.set_auto_install_sup_obj(true);
end;
/
@${container_file}
exit
SQL

  app_count="$(application_count "${app_id}")"
  [ "${app_count:-0}" -eq 1 ] || fail "App ${app_id} was not found after import."
  log "OK: imported App ${app_id}."
}

verify_apps() {
  local expected_csv installed_count app101_count
  expected_csv="$(IFS=,; printf '%s' "${APP_IDS[*]}")"

  installed_count="$(sql_sys "select 'INSTALLED_COUNT=' || count(*) from apex_applications where workspace = upper('${APEX_WORKSPACE_NAME}') and application_id in (${expected_csv});" |
    sed -n 's/^[[:space:]]*INSTALLED_COUNT=//p' | tail -1)"
  [ "${installed_count:-0}" -eq "${#APP_IDS[@]}" ] ||
    fail "Expected ${#APP_IDS[@]} Lab 18 apps, found ${installed_count:-0}."

  sql_sys "
set pages 100
set heading on
set feedback on
column application_name format a48
column alias format a28
select application_id, application_name, alias
  from apex_applications
 where workspace = upper('${APEX_WORKSPACE_NAME}')
   and application_id in (${expected_csv})
 order by application_id;
"

  app101_count="$(application_count 101)"
  if [ "${app101_count:-0}" -eq 1 ]; then
    log "OK: manually managed GoldenGate Console App 101 is present."
  else
    log "INFO: App 101 is intentionally not imported by lab18_init.sh; follow the manual Console import section when required."
  fi
  log "OK: verified ${installed_count} Lab 18 business applications."
}

main() {
  local app_id

  log "==> START: lab18-init"
  log "INFO: Target App Builder -> http://localhost:${HOST_ORDS_PORT}/ords/"
  log "INFO: App 101 remains a separate manual import; this script manages Apps ${APP_IDS[*]}."

  require_prerequisites
  stage_file "${APP_DIR}/repair_subscribed_theme.sql" "${CONTAINER_APP_DIR}/repair_subscribed_theme.sql" "Theme 42 repair SQL"

  for app_id in "${APP_IDS[@]}"; do
    stage_file "${APP_DIR}/f${app_id}.sql" "${CONTAINER_APP_DIR}/f${app_id}.sql" "App ${app_id} export"
    import_app "${app_id}"
  done

  verify_apps
  trap - ERR
  log "OK: Lab 18 APEX business applications are ready."
  log "OK: elapsed time: $(elapsed)"
  log "OK: log file: ${LOG_FILE}"
}

main "$@"
