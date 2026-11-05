#!/usr/bin/env bash

set -Eeuo pipefail

LAB12_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${LAB12_DIR}/lab12_common.sh"

lab12_begin_stage "lab12-install-ords"

ORDS_ARCHIVE="/home/oracle/pkg/ords-26.2.3.237.1104.zip"
ORDS_HOME="/home/oracle/ords"
ORDS_CONFIG="/home/oracle/ords_config"
ORDS_LOGS="/home/oracle/ords_logs"
ORDS_EXPECTED_VERSION_PATTERN="${ORDS_EXPECTED_VERSION_PATTERN:-26.2.3}"
ORDS_INSTALL_TIMEOUT_SECONDS="${ORDS_INSTALL_TIMEOUT_SECONDS:-1800}"
ORDS_READY_TIMEOUT_SECONDS="${ORDS_READY_TIMEOUT_SECONDS:-180}"
JDK_HOST_RPM="${JDK_HOST_RPM:-${LAB_HOME}/centos/pkg/jdk-21_linux-x64_bin.rpm}"
JDK_CONTAINER_RPM="/home/oracle/pkg/jdk-21_linux-x64_bin.rpm"

lab12_require_command docker
lab12_require_command timeout
lab12_require_running_container

if ! lab12_find_ords_java_home >/dev/null 2>&1; then
  if [ ! -f "${JDK_HOST_RPM}" ]; then
    lab12_log "ERROR: Oracle JDK 21 RPM is not staged: ${JDK_HOST_RPM}"
    lab12_log "ERROR: prepare the Chapter 3 download before running Chapter 12 setup."
    exit 1
  fi

  lab12_log "==> Install Oracle JDK 21 in ${TARGET_DB_CONTAINER}"
  docker cp "${JDK_HOST_RPM}" "${TARGET_DB_CONTAINER}:${JDK_CONTAINER_RPM}"
  docker exec -u root "${TARGET_DB_CONTAINER}" rpm -Uvh --replacepkgs "${JDK_CONTAINER_RPM}"
fi
lab12_require_ords_java

apex_state="$(lab12_apex_registry_state)"
if [ "${apex_state}" != "26.1.0|VALID" ]; then
  lab12_log "ERROR: ORDS setup requires APEX 26.1.0|VALID, found: ${apex_state:-not installed}"
  exit 1
fi

if ! docker exec "${TARGET_DB_CONTAINER}" test -f "${ORDS_ARCHIVE}"; then
  lab12_log "ERROR: ORDS archive is not staged: ${ORDS_ARCHIVE}"
  lab12_log "ERROR: run lab12_prepare_media.sh first."
  exit 1
fi

lab12_log "==> Extract Oracle REST Data Services 26.2.3"
docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
  "mkdir -p '${ORDS_HOME}' '${ORDS_CONFIG}' '${ORDS_LOGS}' && unzip -q -o '${ORDS_ARCHIVE}' -d '${ORDS_HOME}'"

if ! docker exec "${TARGET_DB_CONTAINER}" test -x "${ORDS_HOME}/bin/ords"; then
  lab12_log "ERROR: ORDS executable was not extracted: ${ORDS_HOME}/bin/ords"
  exit 1
fi

ords_version="$(docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
  "export JAVA_HOME='${ORDS_JAVA_HOME}'; export PATH=\"\${JAVA_HOME}/bin:\${PATH}\"; '${ORDS_HOME}/bin/ords' --config '${ORDS_CONFIG}' --version 2>&1" \
  | sed -n '/Oracle REST Data Services [0-9]/p' | tail -1)"
case "${ords_version}" in
  *"${ORDS_EXPECTED_VERSION_PATTERN}"*)
    lab12_log "OK: ${ords_version}"
    ;;
  *)
    lab12_log "ERROR: unexpected ORDS product version: ${ords_version:-not found}"
    exit 1
    ;;
esac

ords_user_count="$(lab12_ords_user_count)"
if [ "${ords_user_count:-0}" -ne 0 ] && [ "${ords_user_count}" -ne 2 ]; then
  lab12_log "ERROR: partial ORDS database installation detected: ${ords_user_count} of 2 users exist."
  lab12_log "ERROR: run check_lab12.sh and review the recovery guide."
  exit 1
fi

if [ "${ords_user_count:-0}" -eq 2 ] && docker exec "${TARGET_DB_CONTAINER}" test -f "${ORDS_CONFIG}/databases/default/pool.xml"; then
  lab12_log "SKIP: ORDS database schema and default pool configuration already exist."
else
  lab12_log "==> Install or reconcile ORDS schema and default pool for ${TARGET_PDB}"
  lab12_log "INFO: timeout: ${ORDS_INSTALL_TIMEOUT_SECONDS}s"
  timeout "${ORDS_INSTALL_TIMEOUT_SECONDS}" \
    docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
    "export JAVA_HOME='${ORDS_JAVA_HOME}'; export PATH=\"\${JAVA_HOME}/bin:\${PATH}\"; \
    export ORACLE_HOME=/opt/oracle/product/26ai/dbhome_1; export ORACLE_SID=ORCLCDB; \
    export LD_LIBRARY_PATH=\"\${ORACLE_HOME}/lib:\${LD_LIBRARY_PATH:-}\"; \
    '${ORDS_HOME}/bin/ords' --java-options '-DuseOracleHome=true' --config '${ORDS_CONFIG}' install \
      --bequeath-connect \
      --proxy-user \
      --db-hostname localhost \
      --db-port 1521 \
      --db-servicename '${TARGET_PDB}' \
      --log-folder '${ORDS_LOGS}' \
      --feature-sdw false \
      --password-stdin <<'PASSWORDS'
${LAB_PASSWORD}
PASSWORDS"
fi

lab12_log "==> Configure ORDS for APEX"
resolved_apex_static_path="$(lab12_find_apex_static_path)" || {
  lab12_log "ERROR: APEX static resources were not found in a supported location."
  exit 1
}
lab12_log "INFO: APEX static resources: ${resolved_apex_static_path}"
docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
  "export JAVA_HOME='${ORDS_JAVA_HOME}'; export PATH=\"\${JAVA_HOME}/bin:\${PATH}\"; '${ORDS_HOME}/bin/ords' --config '${ORDS_CONFIG}' config set standalone.static.path '${resolved_apex_static_path}' >/dev/null"
docker exec -u oracle "${TARGET_DB_CONTAINER}" bash -lc \
  "export JAVA_HOME='${ORDS_JAVA_HOME}'; export PATH=\"\${JAVA_HOME}/bin:\${PATH}\"; '${ORDS_HOME}/bin/ords' --config '${ORDS_CONFIG}' config set plsql.gateway.mode proxied >/dev/null"

if ! docker exec "${TARGET_DB_CONTAINER}" test -f /home/oracle/pkg/start_ords.sh; then
  lab12_log "ERROR: ORDS startup helper is not staged: /home/oracle/pkg/start_ords.sh"
  exit 1
fi

docker exec -u root "${TARGET_DB_CONTAINER}" bash -lc \
  "mkdir -p /home/oracle/apex && cp -p /home/oracle/pkg/start_ords.sh /home/oracle/apex/start_ords.sh && chown oracle:oinstall /home/oracle/apex/start_ords.sh && chmod 755 /home/oracle/apex/start_ords.sh"

lab12_log "==> Start ORDS in background"
docker exec -u oracle "${TARGET_DB_CONTAINER}" /home/oracle/apex/start_ords.sh

lab12_log "==> Wait for ORDS endpoint"
ready=0
for ((waited = 0; waited < ORDS_READY_TIMEOUT_SECONDS; waited += 5)); do
  if docker exec "${TARGET_DB_CONTAINER}" bash -lc \
    "if command -v curl >/dev/null 2>&1; then curl -fsS --max-time 5 http://127.0.0.1:8080/ords/ >/dev/null; else timeout 5 bash -lc '</dev/tcp/127.0.0.1/8080'; fi"; then
    ready=1
    break
  fi
  sleep 5
done

if [ "${ready}" -ne 1 ]; then
  lab12_log "ERROR: ORDS endpoint did not become ready within ${ORDS_READY_TIMEOUT_SECONDS}s."
  lab12_log "ERROR: inspect ${TARGET_DB_CONTAINER}:${ORDS_LOGS}/ords-standalone.log"
  exit 1
fi

ords_user_count="$(lab12_ords_user_count)"
if [ "${ords_user_count:-0}" -ne 2 ]; then
  lab12_log "ERROR: ORDS database user validation failed: ${ords_user_count:-0} of 2 users exist."
  exit 1
fi

lab12_log "OK: ORDS is installed and serving APEX on port 8080."
lab12_finish_stage
