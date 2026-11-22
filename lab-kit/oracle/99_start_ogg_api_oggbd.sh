#!/usr/bin/env bash
set -u

API_SCRIPT="/u01/ogg_api_server.py"
LOG_FILE="/u01/ogg/scripts/ogg_api_server.log"

if [ ! -x "${API_SCRIPT}" ]; then
  echo "OGG API server script not found or not executable: ${API_SCRIPT}" >&2
  exit 0
fi

if pgrep -f "${API_SCRIPT}" >/dev/null 2>&1; then
  echo "OGG API server is already running."
  exit 0
fi

nohup env \
  OGG_URL="${OGG_URL:-http://localhost:9012}" \
  OGG_DEPLOYMENT="${OGG_DEPLOYMENT:-OGGBD}" \
  OGG_USER="${OGG_USER:-${OGG_ADMIN:-${OGG_REST_USER:-oggadmin}}}" \
  OGG_PASS="${OGG_PASS:-${OGG_ADMIN_PWD:-${OGG_REST_PASSWORD:-WElcome1234##}}}" \
  "${API_SCRIPT}" 8765 >"${LOG_FILE}" 2>&1 &

echo "Started OGG API server on port 8765."
