#!/bin/bash
set -euo pipefail
OGG_USER=${OGG_USER:-oggadmin}
OGG_PASSWORD=${OGG_PASSWORD:-WElcome1234##}
URL=${URL:-http://localhost:9113/services/v2/stream/DS_LAKE}

response=$(curl -sS -u "${OGG_USER}:${OGG_PASSWORD}" "${URL}")

if command -v jq >/dev/null 2>&1 &&
  formatted=$(printf '%s' "${response}" | jq . 2>/dev/null); then
  printf '%s\n' "${formatted}"
elif command -v python3 >/dev/null 2>&1 &&
  formatted=$(printf '%s' "${response}" | python3 -m json.tool 2>/dev/null); then
  printf '%s\n' "${formatted}"
else
  printf '%s\n' "${response}"
fi
