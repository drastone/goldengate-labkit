#!/bin/bash
set -euo pipefail
source ./env.sh

if [ -z "${OGG_PASS:-}" ]; then
  read -rsp "OGG Password: " OGG_PASS
  echo
  export OGG_PASS
fi

extract_code="$(curl -k -sS -o /dev/null -w '%{http_code}' \
  -u "${OGG_USER}:${OGG_PASS}" \
  "${OGG_BASE_URL}/extracts/CR01")"

if [ "${extract_code}" != "200" ]; then
  echo "ERROR: CR01 Extract does not exist." >&2
  echo "Run sh 04_create_cr01_extract.sh and verify CR01 with sh 01_check_extracts.sh first." >&2
  exit 1
fi

curl -k -sS -u "${OGG_USER}:${OGG_PASS}" \
  -H "Content-Type: application/json" \
  -X PATCH \
  -d '{"registration":{"share":true}}' \
  "${OGG_BASE_URL}/extracts/CR01" \
| python3 -m json.tool
