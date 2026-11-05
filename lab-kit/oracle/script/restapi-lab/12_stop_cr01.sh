#!/bin/bash
set -euo pipefail
source ./env.sh

if [ -z "${OGG_PASS:-}" ]; then
  read -rsp "OGG Password: " OGG_PASS
  echo
  export OGG_PASS
fi

curl -k -sS -u "${OGG_USER}:${OGG_PASS}" \
  -H "Content-Type: application/json" \
  -X PATCH \
  -d '{"status":"stopped"}' \
  "${OGG_BASE_URL}/extracts/CR01" \
| python3 -m json.tool
