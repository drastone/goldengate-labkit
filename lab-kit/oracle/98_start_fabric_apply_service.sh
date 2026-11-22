#!/usr/bin/env bash
set -u

SERVICE_SCRIPT="/u01/fabric_apply_service.py"
LOG_FILE="/u01/ogg/scripts/fabric_apply_service.log"
PID_FILE="/u01/ogg/scripts/fabric_apply_service.pid"
SERVICE_PORT="${FABRIC_APPLY_PORT:-18091}"
FABRIC_APPLY_TOKEN="${FABRIC_APPLY_TOKEN:-lab20-fabric-apply-token}"

if [ ! -x "${SERVICE_SCRIPT}" ]; then
  echo "Data Fabric apply helper script not found or not executable: ${SERVICE_SCRIPT}" >&2
  exit 0
fi

if [ -f "${PID_FILE}" ]; then
  old_pid="$(cat "${PID_FILE}" 2>/dev/null || true)"
  if [ -n "${old_pid}" ] && kill -0 "${old_pid}" >/dev/null 2>&1; then
    if curl -fsS --max-time 3 "http://127.0.0.1:${SERVICE_PORT}/health" >/dev/null 2>&1; then
      echo "Data Fabric apply helper is already running on port ${SERVICE_PORT}."
      exit 0
    fi
    kill "${old_pid}" >/dev/null 2>&1 || true
    sleep 1
  fi
fi

if pgrep -f "${SERVICE_SCRIPT}" >/dev/null 2>&1; then
  pkill -f "${SERVICE_SCRIPT}" >/dev/null 2>&1 || true
  sleep 1
fi

nohup env \
  FABRIC_APPLY_PORT="${SERVICE_PORT}" \
  FABRIC_APPLY_TOKEN="${FABRIC_APPLY_TOKEN}" \
  python3 "${SERVICE_SCRIPT}" >"${LOG_FILE}" 2>&1 &

echo "$!" >"${PID_FILE}"
echo "Started Data Fabric apply helper on port ${SERVICE_PORT}."
