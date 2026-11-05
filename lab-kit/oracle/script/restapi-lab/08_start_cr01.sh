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
  -d '{"status":"running"}' \
  "${OGG_BASE_URL}/extracts/CR01" \
| python3 -m json.tool

echo "==> Wait for CR01 LogMiner attachment"
for attempt in {1..30}; do
  if docker exec demo_ogg_23ai grep -Fq \
    'successfully attached to logmining server OGG$CAP_CR01' \
    /u02/Deployment/var/lib/report/CR01.rpt 2>/dev/null; then
    echo "OK: CR01 is attached to the LogMiner server."
    exit 0
  fi
  sleep 3
done

echo "ERROR: CR01 did not attach to the LogMiner server within 90 seconds." >&2
exit 1
