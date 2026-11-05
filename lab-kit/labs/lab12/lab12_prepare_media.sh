#!/usr/bin/env bash

set -Eeuo pipefail

LAB12_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LAB12_DIR}/lab12_common.sh"

lab12_begin_stage "lab12-prepare-media"

PKG_DIR="${PKG_DIR:-${LAB_HOME}/oracle/pkg}"
APEX_FILE="apex_26.1.zip"
APEX_SHA256="06df14e7c8465747ee45c36c5a0b09821bf2b244db0e201d3cc44abb0403f023"
ORDS_FILE="ords-26.2.3.237.1104.zip"
ORDS_SHA1="290626c955d153602d7e9fe5c78978a86051b414"

fail_missing_media() {
  lab12_log "ERROR: required Oracle media was not found: $1"
  lab12_log "ERROR: Chapter 3 check_labkit.sh must pass before Chapter 12 setup."
  return 1
}

verify_checksum() {
  local algorithm="$1"
  local expected="$2"
  local file="$3"
  local actual

  actual="$(${algorithm} "${file}" | awk '{print $1}')"
  if [ "${actual}" != "${expected}" ]; then
    lab12_log "ERROR: checksum mismatch: ${file}"
    lab12_log "ERROR: expected: ${expected}"
    lab12_log "ERROR: actual:   ${actual}"
    return 1
  fi
  lab12_log "OK: ${algorithm} ${file}"
}

copy_if_needed() {
  local source_file="$1"
  local target_file="$2"
  local algorithm="$3"
  local expected="$4"
  local current=""

  if docker exec "${TARGET_DB_CONTAINER}" test -f "${target_file}" >/dev/null 2>&1; then
    current="$(docker exec "${TARGET_DB_CONTAINER}" "${algorithm}" "${target_file}" 2>/dev/null | awk '{print $1}')"
  fi

  if [ "${current}" = "${expected}" ]; then
    lab12_log "SKIP: already staged in ${TARGET_DB_CONTAINER}: ${target_file}"
    return 0
  fi

  lab12_log "==> Copy $(basename "${source_file}") to ${TARGET_DB_CONTAINER}:${target_file}"
  docker cp "${source_file}" "${TARGET_DB_CONTAINER}:${target_file}"
  docker exec -u root "${TARGET_DB_CONTAINER}" chown oracle:oinstall "${target_file}"
  docker exec -u root "${TARGET_DB_CONTAINER}" chmod 644 "${target_file}"

  current="$(docker exec "${TARGET_DB_CONTAINER}" "${algorithm}" "${target_file}" | awk '{print $1}')"
  [ "${current}" = "${expected}" ] || {
    lab12_log "ERROR: copied file checksum mismatch: ${target_file}"
    return 1
  }
  lab12_log "OK: staged in ${TARGET_DB_CONTAINER}: ${target_file}"
}

for command_name in docker unzip sha256sum sha1sum awk; do
  lab12_require_command "${command_name}"
done

APEX_PATH="${PKG_DIR}/${APEX_FILE}"
ORDS_PATH="${PKG_DIR}/${ORDS_FILE}"

[ -f "${APEX_PATH}" ] || fail_missing_media "${APEX_PATH}"
[ -f "${ORDS_PATH}" ] || fail_missing_media "${ORDS_PATH}"

verify_checksum sha256sum "${APEX_SHA256}" "${APEX_PATH}"
verify_checksum sha1sum "${ORDS_SHA1}" "${ORDS_PATH}"
unzip -tq "${APEX_PATH}" >/dev/null
lab12_log "OK: ZIP structure ${APEX_PATH}"
unzip -tq "${ORDS_PATH}" >/dev/null
lab12_log "OK: ZIP structure ${ORDS_PATH}"

lab12_require_running_container
docker exec -u root "${TARGET_DB_CONTAINER}" mkdir -p /home/oracle/pkg
copy_if_needed "${APEX_PATH}" "/home/oracle/pkg/${APEX_FILE}" sha256sum "${APEX_SHA256}"
copy_if_needed "${ORDS_PATH}" "/home/oracle/pkg/${ORDS_FILE}" sha1sum "${ORDS_SHA1}"

if [ -f "${PKG_DIR}/start_ords.sh" ]; then
  docker cp "${PKG_DIR}/start_ords.sh" "${TARGET_DB_CONTAINER}:/home/oracle/pkg/start_ords.sh"
  docker exec -u root "${TARGET_DB_CONTAINER}" chown oracle:oinstall /home/oracle/pkg/start_ords.sh
  docker exec -u root "${TARGET_DB_CONTAINER}" chmod 755 /home/oracle/pkg/start_ords.sh
  lab12_log "OK: ORDS startup helper staged in ${TARGET_DB_CONTAINER}."
fi

lab12_finish_stage
