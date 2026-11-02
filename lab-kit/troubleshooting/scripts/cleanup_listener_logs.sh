#!/usr/bin/env bash
set -u

RETENTION_DAYS="${RETENTION_DAYS:-7}"
MAX_ACTIVE_LOG_MB="${MAX_ACTIVE_LOG_MB:-100}"
LISTENER_DIAG_ROOT="${LISTENER_DIAG_ROOT:-/opt/oracle/diag/tnslsnr}"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

if [ ! -d "${LISTENER_DIAG_ROOT}" ]; then
  log "INFO: listener diag root not found: ${LISTENER_DIAG_ROOT}"
  exit 0
fi

find "${LISTENER_DIAG_ROOT}" -mindepth 2 -maxdepth 2 -type d -name listener | while read -r diag_dir; do
  log "INFO: cleaning listener diag dir: ${diag_dir}"

  find "${diag_dir}/alert" -maxdepth 1 -type f -name 'log_*.xml' \
    -mtime +"${RETENTION_DAYS}" -delete 2>/dev/null || true

  find "${diag_dir}/trace" -maxdepth 1 -type f -name 'listener_*.log' \
    -mtime +"${RETENTION_DAYS}" -delete 2>/dev/null || true

  find "${diag_dir}/incident" -mindepth 1 -maxdepth 1 \
    -mtime +"${RETENTION_DAYS}" -exec rm -rf {} + 2>/dev/null || true

  find "${diag_dir}/cdump" -mindepth 1 -maxdepth 1 \
    -mtime +"${RETENTION_DAYS}" -exec rm -rf {} + 2>/dev/null || true

  active_log="${diag_dir}/trace/listener.log"
  if [ -f "${active_log}" ]; then
    size_bytes="$(stat -c %s "${active_log}" 2>/dev/null || echo 0)"
    max_bytes=$((MAX_ACTIVE_LOG_MB * 1024 * 1024))

    if [ "${size_bytes}" -gt "${max_bytes}" ]; then
      log "INFO: truncating active listener log over ${MAX_ACTIVE_LOG_MB}MB: ${active_log}"
      : > "${active_log}"
    else
      log "OK: active listener log below ${MAX_ACTIVE_LOG_MB}MB"
    fi
  fi
done
