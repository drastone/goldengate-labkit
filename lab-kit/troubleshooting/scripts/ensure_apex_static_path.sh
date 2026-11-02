#!/usr/bin/env bash
set -u

ORDS_HOME="${ORDS_HOME:-/home/oracle/ords}"
ORDS_CONFIG="${ORDS_CONFIG:-/home/oracle/ords_config}"
APEX_STATIC_PATH="${APEX_STATIC_PATH:-/home/oracle/apex_install/apex/images}"
JAVA_HOME="${JAVA_HOME:-/usr/java/jdk-17}"

if [ ! -x "${ORDS_HOME}/bin/ords" ] && [ -x /home/oracle/ords_new/bin/ords ]; then
  ORDS_HOME="/home/oracle/ords_new"
fi

for candidate in /home/oracle/apex_install/apex/images /home/oracle/apex/images /home/oracle/ords_images/i; do
  if [ ! -f "${APEX_STATIC_PATH}/apex_version.txt" ] && [ -f "${candidate}/apex_version.txt" ]; then
    APEX_STATIC_PATH="${candidate}"
  fi
done

export JAVA_HOME
export PATH="${JAVA_HOME}/bin:${ORDS_HOME}/bin:${PATH}"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

if [ ! -d "${APEX_STATIC_PATH}" ]; then
  log "WARN: APEX static path does not exist: ${APEX_STATIC_PATH}"
  exit 2
fi

if [ ! -f "${APEX_STATIC_PATH}/apex_version.txt" ]; then
  log "WARN: apex_version.txt not found under ${APEX_STATIC_PATH}"
  exit 3
fi

if [ -x "${ORDS_HOME}/bin/ords" ]; then
  ORDS_CMD="${ORDS_HOME}/bin/ords"
elif [ -f "${ORDS_HOME}/ords.war" ]; then
  ORDS_CMD="java -jar ${ORDS_HOME}/ords.war"
else
  log "ERROR: ORDS command not found under ${ORDS_HOME}"
  exit 4
fi

current="$(${ORDS_CMD} --config "${ORDS_CONFIG}" config get standalone.static.path 2>&1 \
  | awk 'NF { last=$0 } END { print last }')"

if [ "${current}" = "${APEX_STATIC_PATH}" ]; then
  log "OK: standalone.static.path=${APEX_STATIC_PATH}"
  exit 0
fi

log "INFO: setting standalone.static.path to ${APEX_STATIC_PATH}"
${ORDS_CMD} --config "${ORDS_CONFIG}" config set standalone.static.path "${APEX_STATIC_PATH}"

log "INFO: ORDS restart is required for the static path setting to take effect"
