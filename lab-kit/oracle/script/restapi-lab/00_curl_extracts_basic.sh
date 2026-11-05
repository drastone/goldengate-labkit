#!/bin/bash
set -euo pipefail

export OGG_USER=oggadmin

if [ -z "${OGG_PASS:-}" ]; then
  read -rsp "OGG Password: " OGG_PASS
  echo
  export OGG_PASS
fi

curl -k -sS -u "${OGG_USER}:${OGG_PASS}" \
  "https://localhost:8443/services/OGGHUB/adminsrvr/v2/extracts" \
| python3 -m json.tool
