#!/usr/bin/env bash

set -Eeuo pipefail

LAB12_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LAB12_DIR}/lab12_common.sh"

lab12_begin_stage "lab12-install-apex"

APEX_EXPECTED_VERSION="${APEX_EXPECTED_VERSION:-26.1.0}"
APEX_ARCHIVE="/home/oracle/pkg/apex_26.1.zip"
APEX_INSTALL_TIMEOUT_SECONDS="${APEX_INSTALL_TIMEOUT_SECONDS:-3600}"

lab12_require_command docker
lab12_require_command timeout
lab12_require_running_container

apex_state="$(lab12_apex_registry_state)"
if [ "${apex_state}" = "${APEX_EXPECTED_VERSION}|VALID" ]; then
  lab12_log "SKIP: Oracle APEX ${APEX_EXPECTED_VERSION} is already VALID in ${TARGET_PDB}."
  lab12_finish_stage
  exit 0
fi

if [ -n "${apex_state}" ]; then
  lab12_log "ERROR: an unexpected APEX installation exists in ${TARGET_PDB}: ${apex_state}"
  lab12_log "ERROR: run check_lab12.sh and review the recovery guide."
  exit 1
fi

apex_user_count="$(lab12_apex_user_count)"
if [ "${apex_user_count:-0}" -ne 0 ]; then
  lab12_log "ERROR: APEX is absent from DBA_REGISTRY, but ${apex_user_count} APEX-related users remain."
  lab12_log "ERROR: this looks like a partial installation. Do not install over it."
  lab12_log "ERROR: review the log, then use remove_apex.sh only when a full reset is intended."
  exit 1
fi

if ! docker exec "${TARGET_DB_CONTAINER}" test -f "${APEX_ARCHIVE}"; then
  lab12_log "ERROR: APEX archive is not staged in ${TARGET_DB_CONTAINER}: ${APEX_ARCHIVE}"
  lab12_log "ERROR: run lab12_prepare_media.sh first."
  exit 1
fi

lab12_log "==> Prepare dedicated APEX extraction directory: ${APEX_INSTALL_ROOT}"
docker exec -u root "${TARGET_DB_CONTAINER}" bash -lc \
  "mkdir -p '${APEX_INSTALL_ROOT}' && chown -R oracle:oinstall '${APEX_INSTALL_ROOT}' && chmod 755 '${APEX_INSTALL_ROOT}'"

lab12_log "==> Extract Oracle APEX 26.1 in ${TARGET_DB_CONTAINER}:${APEX_INSTALL_ROOT}"
docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
  "unzip -q -o '${APEX_ARCHIVE}' -d '${APEX_INSTALL_ROOT}'"

if ! docker exec "${TARGET_DB_CONTAINER}" test -f "${APEX_HOME}/apxsilentins.sql"; then
  lab12_log "ERROR: apxsilentins.sql was not extracted: ${APEX_HOME}/apxsilentins.sql"
  exit 1
fi

lab12_log "==> Install Oracle APEX ${APEX_EXPECTED_VERSION} in ${TARGET_PDB}"
lab12_log "INFO: this step can take several minutes. Timeout: ${APEX_INSTALL_TIMEOUT_SECONDS}s"

timeout "${APEX_INSTALL_TIMEOUT_SECONDS}" \
  docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
  "cd '${APEX_HOME}' && sqlplus -s / as sysdba <<'SQL'
whenever sqlerror exit failure rollback
set echo on timing on serveroutput on
alter session set container=${TARGET_PDB};
@apxsilentins.sql SYSAUX SYSAUX TEMP /i/ ${LAB_PASSWORD} ${LAB_PASSWORD} ${LAB_PASSWORD} ${LAB_PASSWORD}
exit
SQL"

apex_state="$(lab12_apex_registry_state)"
if [ "${apex_state}" != "${APEX_EXPECTED_VERSION}|VALID" ]; then
  lab12_log "ERROR: APEX validation failed after installation: ${apex_state:-not registered}"
  exit 1
fi

lab12_log "OK: Oracle APEX ${APEX_EXPECTED_VERSION} is VALID in ${TARGET_PDB}."
lab12_log "INFO: detailed Oracle install logs remain in ${TARGET_DB_CONTAINER}:${APEX_HOME}."
lab12_finish_stage
