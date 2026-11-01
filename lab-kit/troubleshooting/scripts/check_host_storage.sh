#!/usr/bin/env bash
set -u

MAX_USED_PERCENT="${LAB_STORAGE_MAX_USED_PERCENT:-85}"
MIN_FREE_GB="${LAB_STORAGE_MIN_FREE_GB:-30}"
STORAGE_PATH="${LAB_STORAGE_PATH:-}"
START_SCRIPT="${LAB_STORAGE_START_SCRIPT:-startDocker.sh}"
START_COMMAND="${LAB_STORAGE_START_COMMAND:-startDocker.sh}"

log() {
  printf '%s\n' "$*"
}

is_non_negative_integer() {
  case "${1:-}" in
    ''|*[!0-9]*) return 1 ;;
    *) return 0 ;;
  esac
}

if ! is_non_negative_integer "${MAX_USED_PERCENT}" || \
   ! is_non_negative_integer "${MIN_FREE_GB}"; then
  log "ERROR: storage thresholds must be non-negative integers"
  exit 1
fi

if [ -z "${STORAGE_PATH}" ]; then
  if [ -d /mnt/d ]; then
    STORAGE_PATH="/mnt/d"
  elif command -v docker >/dev/null 2>&1; then
    STORAGE_PATH="$(docker info --format '{{.DockerRootDir}}' 2>/dev/null || true)"
  fi
fi

if [ -z "${STORAGE_PATH}" ] || [ ! -e "${STORAGE_PATH}" ]; then
  log "ERROR: cannot find the Lab storage path: ${STORAGE_PATH:-not detected}"
  log "ERROR: set LAB_STORAGE_PATH to the Windows drive or filesystem that stores the WSL/Docker Lab."
  exit 1
fi

df_line="$(df -Pk "${STORAGE_PATH}" 2>/dev/null | awk 'NR == 2 {print $4, $5, $6}')"
read -r available_kb used_percent mount_point <<EOF
${df_line}
EOF

used_percent="${used_percent%%%}"
if ! is_non_negative_integer "${available_kb:-}" || \
   ! is_non_negative_integer "${used_percent:-}"; then
  log "ERROR: cannot read storage usage for ${STORAGE_PATH}"
  exit 1
fi

available_gb="$((available_kb / 1024 / 1024))"

df -h "${STORAGE_PATH}"
log "INFO: hold threshold: used >= ${MAX_USED_PERCENT}% or free < ${MIN_FREE_GB}GB"

hold_reason=""
if [ "${used_percent}" -ge "${MAX_USED_PERCENT}" ]; then
  hold_reason="used space is ${used_percent}%"
fi
if [ "${available_gb}" -lt "${MIN_FREE_GB}" ]; then
  if [ -n "${hold_reason}" ]; then
    hold_reason="${hold_reason}; free space is ${available_gb}GB"
  else
    hold_reason="free space is ${available_gb}GB"
  fi
fi

if [ -n "${hold_reason}" ]; then
  log "ERROR: Lab startup is on hold: ${hold_reason}."
  log "ERROR: ${START_SCRIPT} does not delete files automatically."
  log "ERROR: review the Windows drive and WSL/Docker usage, free enough space,"
  log "ERROR: verify it with 'df -h ${STORAGE_PATH}', and then run '${START_COMMAND}' again."
  exit 1
fi

log "OK: Lab storage has passed the startup threshold."
