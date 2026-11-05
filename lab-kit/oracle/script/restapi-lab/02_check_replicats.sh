#!/bin/bash
set -euo pipefail
source ./env.sh

if [ -z "${OGG_PASS:-}" ]; then
  read -rsp "OGG Password: " OGG_PASS
  echo
  export OGG_PASS
fi

printf "%-10s %-12s %-12s\n" "TYPE" "NAME" "STATUS"
curl -k -sS -u "${OGG_USER}:${OGG_PASS}" \
  "${OGG_BASE_URL}/replicats" \
| python3 -c '
import json, sys
data = json.load(sys.stdin)
for item in data.get("response", {}).get("items", []):
    print("{:<10} {:<12} {:<12}".format("REPLICAT", item.get("name", ""), item.get("status", "")))
'
