#!/bin/bash
set -euo pipefail
source ./env.sh

if [ -z "${OGG_PASS:-}" ]; then
  read -rsp "OGG Password: " OGG_PASS
  echo
  export OGG_PASS
fi

stop_process() {
  local resource="$1"
  local name="$2"
  local code response status

  code="$(curl -k -sS -o /dev/null -w '%{http_code}' \
    -u "${OGG_USER}:${OGG_PASS}" \
    "${OGG_BASE_URL}/${resource}/${name}")"

  if [ "${code}" != "200" ]; then
    echo "INFO: ${name} does not exist; skip."
    return
  fi

  echo "==> Stop ${name}"
  response="$(curl -k -sS -u "${OGG_USER}:${OGG_PASS}" \
    -H "Content-Type: application/json" \
    -X PATCH \
    -d '{"status":"stopped"}' \
    "${OGG_BASE_URL}/${resource}/${name}")"

  printf '%s\n' "${response}" | python3 -c '
import json, sys
name = sys.argv[1]
data = json.load(sys.stdin)
messages = data.get("messages", [])
errors = [m for m in messages if m.get("severity") in ("ERROR", "FATAL")]
if errors:
    for message in errors:
        print("ERROR: {}: {}".format(name, message.get("title", "request failed")))
    raise SystemExit(1)
' "${name}"

  for attempt in {1..10}; do
    status="$(curl -k -sS -u "${OGG_USER}:${OGG_PASS}" \
      "${OGG_BASE_URL}/${resource}/${name}" \
      | python3 -c 'import json,sys; print(json.load(sys.stdin).get("response", {}).get("status", "unknown"))')"
    case "${status}" in
      stopped)
        echo "OK: ${name} is stopped."
        return
        ;;
      abended)
        echo "WARN: ${name} is not running, but its status is abended; review the report."
        return
        ;;
    esac
    sleep 1
  done

  echo "ERROR: ${name} did not stop; current status is ${status}." >&2
  exit 1
}

# Stop apply processes before their capture processes.
stop_process replicats DR01
stop_process replicats DW01
stop_process extracts CR01
stop_process extracts CW01

echo "==> Chapter 11 process status"
sh ./00_info_all.sh
