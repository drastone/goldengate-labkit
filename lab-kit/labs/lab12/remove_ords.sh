#!/usr/bin/env bash

set -Eeuo pipefail

LAB12_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LAB12_DIR}/lab12_common.sh"

lab12_begin_stage "remove-ords"

CONFIRM_TEXT="REMOVE-ORDS-${TARGET_PDB}"
ORDS_ARCHIVE="/home/oracle/pkg/ords-26.2.3.237.1104.zip"
ORDS_HOME="/home/oracle/ords"
ORDS_CONFIG="/home/oracle/ords_config"
ORDS_LOGS="/home/oracle/ords_logs"
ORDS_REMOVE_TIMEOUT_SECONDS="${ORDS_REMOVE_TIMEOUT_SECONDS:-1800}"

lab12_require_command docker
lab12_require_command timeout
lab12_require_running_container
lab12_require_ords_java

ords_user_count="$(lab12_ords_user_count)"
if [ "${ords_user_count:-0}" -eq 0 ] && ! docker exec "${TARGET_DB_CONTAINER}" test -d "${ORDS_CONFIG}"; then
  lab12_log "SKIP: ORDS is already absent from ${TARGET_PDB}."
  lab12_finish_stage
  exit 0
fi

lab12_log "WARNING: this removes ORDS database schemas and proxy users from ${TARGET_PDB}."
lab12_log "WARNING: the ORDS configuration directory will be preserved with a timestamped name."
lab12_log "INFO: ORDS-related database user count: ${ords_user_count:-0}"

if [ "${1:-}" != "--confirm" ] || [ "${2:-}" != "${CONFIRM_TEXT}" ]; then
  lab12_log "ERROR: destructive confirmation was not supplied."
  lab12_log "ERROR: run only when a full ORDS reset is intended:"
  lab12_log "ERROR: bash remove_ords.sh --confirm ${CONFIRM_TEXT}"
  exit 2
fi

if ! docker exec "${TARGET_DB_CONTAINER}" test -x "${ORDS_HOME}/bin/ords"; then
  if ! docker exec "${TARGET_DB_CONTAINER}" test -f "${ORDS_ARCHIVE}"; then
    lab12_log "ERROR: ORDS executable and archive are both unavailable."
    exit 1
  fi
  docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
    "mkdir -p '${ORDS_HOME}' && unzip -q -o '${ORDS_ARCHIVE}' -d '${ORDS_HOME}'"
fi

lab12_log "==> Stop ORDS process"
docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
  "pids=\$(ps -eo pid=,comm=,args= | awk '\$2 == \"java\" && index(\$0, \"ords.war\") {print \$1}'); if [ -n \"\${pids}\" ]; then kill \${pids}; sleep 8; fi"

if [ "${ords_user_count:-0}" -gt 0 ]; then
  lab12_log "==> Uninstall ORDS database objects from ${TARGET_PDB}"
  timeout "${ORDS_REMOVE_TIMEOUT_SECONDS}" \
    docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
    "export JAVA_HOME='${ORDS_JAVA_HOME}'; export PATH=\"\${JAVA_HOME}/bin:\${PATH}\"; \
    export ORACLE_HOME=/opt/oracle/product/26ai/dbhome_1; export ORACLE_SID=ORCLCDB; \
    export LD_LIBRARY_PATH=\"\${ORACLE_HOME}/lib:\${LD_LIBRARY_PATH:-}\"; \
    '${ORDS_HOME}/bin/ords' --java-options '-DuseOracleHome=true' --config '${ORDS_CONFIG}' uninstall \
      --bequeath-connect \
      --log-folder '${ORDS_LOGS}'"
fi

backup_suffix="$(lab12_timestamp)"
if docker exec "${TARGET_DB_CONTAINER}" test -d "${ORDS_CONFIG}"; then
  docker exec -u oracle "${TARGET_DB_CONTAINER}" mv "${ORDS_CONFIG}" "${ORDS_CONFIG}.removed.${backup_suffix}"
  lab12_log "OK: preserved ORDS config as ${ORDS_CONFIG}.removed.${backup_suffix}"
fi

ords_user_count="$(lab12_ords_user_count)"
if [ "${ords_user_count:-0}" -ne 0 ]; then
  lab12_log "ERROR: ORDS removal left ${ords_user_count} database users."
  lab12_log "ERROR: do not issue manual DROP USER commands; review the ORDS uninstall log."
  exit 1
fi

lab12_log "OK: ORDS database schemas and proxy users are absent from ${TARGET_PDB}."
lab12_finish_stage
