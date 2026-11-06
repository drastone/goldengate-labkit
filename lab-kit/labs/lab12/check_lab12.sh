#!/usr/bin/env bash

set -Eeuo pipefail

LAB12_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LAB12_DIR}/lab12_common.sh"

lab12_begin_stage "check-lab12"

APEX_EXPECTED_VERSION="${APEX_EXPECTED_VERSION:-26.1.0}"
ORDS_EXPECTED_VERSION_PATTERN="${ORDS_EXPECTED_VERSION_PATTERN:-26.2.3}"
ORDS_HOME="/home/oracle/ords"
ORDS_CONFIG="/home/oracle/ords_config"
APEX_WORKSPACE_NAME="${APEX_WORKSPACE_NAME:-OGG}"
APEX_WORKSPACE_ADMIN="${APEX_WORKSPACE_ADMIN:-GGADMIN}"

lab12_require_command docker
lab12_require_command curl
lab12_require_running_container
lab12_require_ords_java

apex_state="$(lab12_apex_registry_state)"
if [ "${apex_state}" != "${APEX_EXPECTED_VERSION}|VALID" ]; then
  lab12_log "ERROR: expected APEX ${APEX_EXPECTED_VERSION}|VALID, found: ${apex_state:-not installed}"
  exit 1
fi
lab12_log "OK: APEX ${apex_state} in ${TARGET_PDB}."

invalid_apex_objects="$(docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc "sqlplus -s / as sysdba <<'SQL'
set pages 0 feedback off heading off verify off echo off trimspool on
whenever sqlerror exit failure
alter session set container=${TARGET_PDB};
select 'INVALID_APEX_OBJECTS=' || count(*)
from dba_objects
where owner = 'APEX_260100'
  and status = 'INVALID';
exit
SQL" | sed -n 's/^[[:space:]]*INVALID_APEX_OBJECTS=//p' | tail -1)"

if [ "${invalid_apex_objects:-0}" -ne 0 ]; then
  lab12_log "ERROR: invalid APEX_260100 objects: ${invalid_apex_objects}"
  exit 1
fi
lab12_log "OK: invalid APEX_260100 objects: 0"

resolved_apex_static_path="$(lab12_find_apex_static_path)" || {
  lab12_log "ERROR: APEX static resources were not found in a supported location."
  exit 1
}
lab12_log "OK: APEX static resources: ${resolved_apex_static_path}"

ords_user_count="$(lab12_ords_user_count)"
if [ "${ords_user_count:-0}" -ne 2 ]; then
  lab12_log "ERROR: expected ORDS_METADATA and ORDS_PUBLIC_USER, found ${ords_user_count:-0} ORDS users."
  exit 1
fi
lab12_log "OK: ORDS database users are present in ${TARGET_PDB}."

ords_version="$(docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
  "export JAVA_HOME='${ORDS_JAVA_HOME}'; export PATH=\"\${JAVA_HOME}/bin:\${PATH}\"; '${ORDS_HOME}/bin/ords' --config '${ORDS_CONFIG}' --version 2>&1" \
  | sed -n '/Oracle REST Data Services [0-9]/p' | tail -1)"
case "${ords_version}" in
  *"${ORDS_EXPECTED_VERSION_PATTERN}"*)
    lab12_log "OK: ${ords_version}"
    ;;
  *)
    lab12_log "ERROR: unexpected ORDS version: ${ords_version:-not found}"
    exit 1
    ;;
esac

if ! docker exec "${TARGET_DB_CONTAINER}" test -d "${ORDS_CONFIG}"; then
  lab12_log "ERROR: ORDS config directory not found: ${ORDS_CONFIG}"
  exit 1
fi
lab12_log "OK: ORDS config directory: ${ORDS_CONFIG}"

gateway_mode="$(docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
  "export JAVA_HOME='${ORDS_JAVA_HOME}'; export PATH=\"\${JAVA_HOME}/bin:\${PATH}\"; '${ORDS_HOME}/bin/ords' --config '${ORDS_CONFIG}' config get plsql.gateway.mode 2>&1" | awk 'NF { last=$0 } END { print last }')"
if [ "${gateway_mode}" != "proxied" ]; then
  lab12_log "ERROR: expected plsql.gateway.mode=proxied, found: ${gateway_mode:-unset}"
  exit 1
fi
lab12_log "OK: plsql.gateway.mode=proxied"

static_path="$(docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
  "export JAVA_HOME='${ORDS_JAVA_HOME}'; export PATH=\"\${JAVA_HOME}/bin:\${PATH}\"; '${ORDS_HOME}/bin/ords' --config '${ORDS_CONFIG}' config get standalone.static.path 2>&1" | awk 'NF { last=$0 } END { print last }')"
if [ "${static_path}" != "${resolved_apex_static_path}" ]; then
  lab12_log "ERROR: expected standalone.static.path=${resolved_apex_static_path}, found: ${static_path:-unset}"
  exit 1
fi
lab12_log "OK: standalone.static.path=${resolved_apex_static_path}"

if ! docker exec "${TARGET_DB_CONTAINER}" curl -fsS --max-time 10 http://127.0.0.1:8080/ords/ >/dev/null; then
  lab12_log "ERROR: ORDS endpoint is not ready inside ${TARGET_DB_CONTAINER}:8080"
  exit 1
fi
lab12_log "OK: ORDS endpoint inside container: http://127.0.0.1:8080/ords/"

if ! curl -fsS --max-time 10 http://127.0.0.1:36080/ords/ >/dev/null; then
  lab12_log "ERROR: host-published ORDS endpoint is not ready: http://127.0.0.1:36080/ords/"
  exit 1
fi
lab12_log "OK: host-published ORDS endpoint: http://127.0.0.1:36080/ords/"

workspace_count="$(lab12_apex_workspace_count "${APEX_WORKSPACE_NAME}")"
if [ "${workspace_count:-0}" -eq 0 ]; then
  lab12_log "INFO: APEX workspace ${APEX_WORKSPACE_NAME} is not created yet; skip workspace user role check."
  lab12_log "INFO: create the workspace, then run this check again before importing App 101."
else
  workspace_user_state="$(lab12_apex_workspace_user_state "${APEX_WORKSPACE_NAME}" "${APEX_WORKSPACE_ADMIN}")"
  if [ -z "${workspace_user_state}" ]; then
    lab12_log "ERROR: APEX user ${APEX_WORKSPACE_ADMIN} was not found in workspace ${APEX_WORKSPACE_NAME}."
    exit 1
  fi

  IFS='|' read -r actual_workspace actual_user is_admin is_developer is_locked <<<"${workspace_user_state}"
  if [ "${is_admin}" != "Yes" ] || [ "${is_developer}" != "Yes" ] || [ "${is_locked}" != "No" ]; then
    lab12_log "ERROR: ${actual_workspace}.${actual_user} is not ready for App Builder."
    lab12_log "ERROR: is_admin=${is_admin}, is_application_developer=${is_developer}, account_locked=${is_locked}"
    lab12_log "ERROR: open /ords/apex_admin as ADMIN, then Manage Workspaces > Manage Developers and Users."
    lab12_log "ERROR: set User is an administrator=Yes and User is a developer=Yes for ${APEX_WORKSPACE_ADMIN}."
    exit 1
  fi

  lab12_log "OK: ${actual_workspace}.${actual_user} is an unlocked workspace administrator and developer."
fi

lab12_finish_stage
