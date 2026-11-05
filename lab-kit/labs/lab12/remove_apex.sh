#!/usr/bin/env bash

set -Eeuo pipefail

LAB12_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LAB12_DIR}/lab12_common.sh"

lab12_begin_stage "remove-apex"

CONFIRM_TEXT="REMOVE-APEX-${TARGET_PDB}"
APEX_ARCHIVE="/home/oracle/pkg/apex_26.1.zip"
APEX_HOME="/home/oracle/apex"
APEX_REMOVE_TIMEOUT_SECONDS="${APEX_REMOVE_TIMEOUT_SECONDS:-3600}"

lab12_require_command docker
lab12_require_command timeout
lab12_require_running_container

apex_state="$(lab12_apex_registry_state)"
apex_user_count="$(lab12_apex_user_count)"
if [ -z "${apex_state}" ] && [ "${apex_user_count:-0}" -eq 0 ]; then
  lab12_log "SKIP: APEX is already absent from ${TARGET_PDB}."
  lab12_finish_stage
  exit 0
fi

lab12_log "WARNING: this removes APEX from ${TARGET_DB_CONTAINER}/${TARGET_PDB}."
lab12_log "WARNING: APEX applications, workspaces, schemas, users, and synonyms can be deleted."
lab12_log "INFO: current APEX state: ${apex_state:-not registered}"
lab12_log "INFO: APEX-related user count: ${apex_user_count:-0}"

if [ "${1:-}" != "--confirm" ] || [ "${2:-}" != "${CONFIRM_TEXT}" ]; then
  lab12_log "ERROR: destructive confirmation was not supplied."
  lab12_log "ERROR: run only when a full APEX reset is intended:"
  lab12_log "ERROR: bash remove_apex.sh --confirm ${CONFIRM_TEXT}"
  exit 2
fi

if ! docker exec "${TARGET_DB_CONTAINER}" test -f "${APEX_HOME}/apxremov.sql"; then
  if ! docker exec "${TARGET_DB_CONTAINER}" test -f "${APEX_ARCHIVE}"; then
    lab12_log "ERROR: apxremov.sql and APEX archive are both unavailable."
    lab12_log "ERROR: run lab12_prepare_media.sh before removal."
    exit 1
  fi
  lab12_log "==> Extract APEX removal scripts"
  docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
    "cd /home/oracle && unzip -q -o '${APEX_ARCHIVE}'"
fi

lab12_log "==> Run Oracle apxremov.sql in ${TARGET_PDB}"
timeout "${APEX_REMOVE_TIMEOUT_SECONDS}" \
  docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
  "cd '${APEX_HOME}' && sqlplus -s / as sysdba <<'SQL'
whenever sqlerror exit failure rollback
set echo on timing on serveroutput on
alter session set container=${TARGET_PDB};
@apxremov.sql
exit
SQL"

apex_state="$(lab12_apex_registry_state)"
apex_user_count="$(lab12_apex_user_count)"
if [ -n "${apex_state}" ] || [ "${apex_user_count:-0}" -ne 0 ]; then
  lab12_log "ERROR: APEX removal left registry or schema entries."
  lab12_log "ERROR: registry state: ${apex_state:-absent}"
  lab12_log "ERROR: APEX-related user count: ${apex_user_count:-0}"
  lab12_log "ERROR: do not issue manual DROP USER commands; review the Oracle removal log."
  exit 1
fi

lab12_log "OK: Oracle APEX and APEX-related schemas are absent from ${TARGET_PDB}."
lab12_log "INFO: ORDS is a separate product and is not removed by this script."
lab12_finish_stage
