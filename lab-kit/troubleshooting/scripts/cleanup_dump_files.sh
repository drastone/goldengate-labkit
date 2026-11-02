#!/usr/bin/env bash
set -u

RETENTION_DAYS="${RETENTION_DAYS:-7}"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

log "INFO: dump/trace cleanup start. RETENTION_DAYS=${RETENTION_DAYS}"

for base in /opt/oracle/diag/rdbms /opt/oracle/diag/clients /opt/oracle/admin; do
  [ -d "${base}" ] || continue

  find "${base}" -type f \( \
      -name '*.trc' -o \
      -name '*.trm' -o \
      -name '*.aud' -o \
      -name '*.log' \
    \) -mtime +"${RETENTION_DAYS}" -delete 2>/dev/null || true
done

log "INFO: dump/trace cleanup complete"
