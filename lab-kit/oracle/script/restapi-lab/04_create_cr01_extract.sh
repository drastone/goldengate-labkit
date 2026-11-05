#!/bin/bash
set -euo pipefail
source ./env.sh

if [ -z "${OGG_PASS:-}" ]; then
  read -rsp "OGG Password: " OGG_PASS
  echo
  export OGG_PASS
fi

response="$(curl -k -sS -u "${OGG_USER}:${OGG_PASS}" \
  -H "Content-Type: application/json" \
  -X POST \
  -d @03_create_cr01_extract.json \
  "${OGG_BASE_URL}/extracts/CR01")"

printf '%s\n' "${response}" | python3 -m json.tool

printf '%s\n' "${response}" | python3 -c '
import json, sys
data = json.load(sys.stdin)
messages = data.get("messages", [])
errors = [m for m in messages if m.get("severity") in ("ERROR", "FATAL")]
registered = any(m.get("code") == "OGG-02003" for m in messages)
if errors or not registered:
    print("ERROR: CR01 creation or database registration did not complete.", file=sys.stderr)
    raise SystemExit(1)
'

extract_code="$(curl -k -sS -o /dev/null -w '%{http_code}' \
  -u "${OGG_USER}:${OGG_PASS}" \
  "${OGG_BASE_URL}/extracts/CR01")"

if [ "${extract_code}" != "200" ]; then
  echo "ERROR: CR01 Extract was not created. Review the REST response above." >&2
  exit 1
fi
