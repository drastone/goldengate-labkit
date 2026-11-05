#!/usr/bin/env bash
set -u

# Start ORDS in the background for the Lab Kit.
#
# ORDS interactive install starts a foreground Jetty process. That is useful
# during installation, but readers should not have to keep that terminal open.
# This script is safe to run repeatedly: it starts ORDS only when no matching
# ORDS process is already running.

ORDS_HOME="${ORDS_HOME:-/home/oracle/ords}"
ORDS_CONFIG="${ORDS_CONFIG:-/home/oracle/ords_config}"
ORDS_LOG_DIR="${ORDS_LOG_DIR:-/home/oracle/ords_logs}"
ORDS_LOG_FILE="${ORDS_LOG_FILE:-${ORDS_LOG_DIR}/ords-standalone.log}"
ORDS_IDLE_TIMEOUT_MS="${ORDS_IDLE_TIMEOUT_MS:-300000}"
ORDS_HTTP_PORT="${ORDS_HTTP_PORT:-8080}"
APEX_STATIC_PATH="${APEX_STATIC_PATH:-}"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

if [ ! -x "${ORDS_HOME}/bin/ords" ] && [ -x /home/oracle/ords_new/bin/ords ]; then
  ORDS_HOME="/home/oracle/ords_new"
fi

java_major_version() {
  "$1/bin/java" -version 2>&1 | awk -F'[ ".]+' '/version/ { print $3; exit }'
}

is_java17_home() {
  candidate="$1"

  [ -x "${candidate}/bin/java" ] || return 1
  java_major="$(java_major_version "${candidate}")"
  [ -n "${java_major}" ] && [ "${java_major}" -ge 17 ]
}

find_java17_home() {
  if [ -n "${JAVA_HOME:-}" ] && is_java17_home "${JAVA_HOME}"; then
    printf '%s\n' "${JAVA_HOME}"
    return 0
  fi

  for candidate in /usr/java/default /usr/java/latest /usr/java/jdk-* /usr/lib/jvm/jdk-* /usr/lib/jvm/java-*; do
    if is_java17_home "${candidate}"; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done

  return 1
}

if ! JAVA_HOME="$(find_java17_home)"; then
  log "ERROR: Java 17 or later was not found."
  exit 3
fi

export JAVA_HOME
export PATH="${JAVA_HOME}/bin:${ORDS_HOME}/bin:${PATH}"

if [ ! -x "${ORDS_HOME}/bin/ords" ]; then
  log "ERROR: ORDS command not found: ${ORDS_HOME}/bin/ords"
  exit 1
fi

if [ ! -d "${ORDS_CONFIG}" ]; then
  log "ERROR: ORDS config directory not found: ${ORDS_CONFIG}"
  exit 2
fi

find_apex_static_path() {
  if [ -n "${APEX_STATIC_PATH}" ] && [ -f "${APEX_STATIC_PATH}/apex_version.txt" ]; then
    printf '%s\n' "${APEX_STATIC_PATH}"
    return 0
  fi

  for candidate in \
    /home/oracle/apex_install/apex/images \
    /home/oracle/apex/images \
    /home/oracle/ords_images/i; do
    if [ -f "${candidate}/apex_version.txt" ]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done

  return 1
}

ords_pids() {
  ps -eo pid=,comm=,args= |
    awk -v cfg="${ORDS_CONFIG}" '
      $2 == "java" &&
      index($0, "ords.war") &&
      index($0, cfg) {
        print $1
      }'
}

ords_endpoint_is_ready() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsS --max-time 5 "http://127.0.0.1:${ORDS_HTTP_PORT}/ords/" >/dev/null 2>&1
    return $?
  fi

  timeout 5 bash -lc "</dev/tcp/127.0.0.1/${ORDS_HTTP_PORT}" >/dev/null 2>&1
}

stop_stale_ords() {
  mapfile -t pids < <(ords_pids)
  [ "${#pids[@]}" -gt 0 ] || return 0

  log "ORDS process exists but endpoint is not responding; restart stale process: ${pids[*]}"
  kill "${pids[@]}" 2>/dev/null || true
  sleep 8

  mapfile -t pids < <(ords_pids)
  if [ "${#pids[@]}" -gt 0 ]; then
    log "ORDS process did not stop cleanly; force stop: ${pids[*]}"
    kill -9 "${pids[@]}" 2>/dev/null || true
    sleep 3
  fi
}

jetty_etc_dir="${ORDS_CONFIG}/global/standalone/etc"
jetty_http_file="${jetty_etc_dir}/jetty-http.xml"
mkdir -p "${jetty_etc_dir}"
cat > "${jetty_http_file}" <<EOF
<?xml version="1.0"?>
<!DOCTYPE Configure PUBLIC "-//Jetty//Configure//EN" "http://www.eclipse.org/jetty/configure.dtd">
<Configure id="httpConfig" class="org.eclipse.jetty.server.HttpConfiguration">
  <Set name="idleTimeout">${ORDS_IDLE_TIMEOUT_MS}</Set>
</Configure>
EOF

if APEX_STATIC_PATH="$(find_apex_static_path)"; then
  current_static_path="$("${ORDS_HOME}/bin/ords" --config "${ORDS_CONFIG}" config get standalone.static.path 2>&1 | awk 'NF { last=$0 } END { print last }')"
  if [ "${current_static_path}" != "${APEX_STATIC_PATH}" ]; then
    log "Set APEX static path: ${APEX_STATIC_PATH}"
    "${ORDS_HOME}/bin/ords" --config "${ORDS_CONFIG}" config set standalone.static.path "${APEX_STATIC_PATH}" >/dev/null
  fi
else
  log "WARN: APEX static files were not found; /i/* resources may return 404."
fi

mapfile -t running_pids < <(ords_pids)
if [ "${#running_pids[@]}" -gt 0 ]; then
  if ords_endpoint_is_ready; then
    log "ORDS is already running for config ${ORDS_CONFIG}."
    exit 0
  fi

  stop_stale_ords
fi

mkdir -p "${ORDS_LOG_DIR}"

nohup "${ORDS_HOME}/bin/ords" \
  --config "${ORDS_CONFIG}" \
  serve \
  > "${ORDS_LOG_FILE}" 2>&1 &

log "ORDS started in background. pid=$! log=${ORDS_LOG_FILE}"
