#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASK_FILE="${SCRIPT_DIR}/purge-ogghub-trails.json"
OGGHUB_CONTAINER="${OGGHUB_CONTAINER:-demo_ogg_23ai}"
OGG_ADMIN_USER="${OGG_ADMIN_USER:-oggadmin}"
OGG_ADMIN_PASSWORD="${OGG_ADMIN_PASSWORD:-WElcome1234##}"
TASK_NAME="${TASK_NAME:-PURGE_OGGHUB_TRAILS}"
API_ROOT="${API_ROOT:-http://localhost/services/OGGHUB/adminsrvr/v2}"
TASK_URL="${API_ROOT}/tasks/${TASK_NAME}"

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

request() {
  local method="$1"
  local url="$2"
  local data_file="${3:-}"

  if [[ -n "${data_file}" ]]; then
    docker exec -i "${OGGHUB_CONTAINER}" \
      curl -sS -u "${OGG_ADMIN_USER}:${OGG_ADMIN_PASSWORD}" \
      -H 'Content-Type: application/json' \
      -X "${method}" "${url}" -d @- <"${data_file}"
  else
    docker exec "${OGGHUB_CONTAINER}" \
      curl -sS -u "${OGG_ADMIN_USER}:${OGG_ADMIN_PASSWORD}" \
      -X "${method}" "${url}"
  fi
}

command -v docker >/dev/null 2>&1 || fail "docker command was not found"
command -v python3 >/dev/null 2>&1 || fail "python3 command was not found"
[[ -r "${TASK_FILE}" ]] || fail "task definition was not found: ${TASK_FILE}"
python3 -m json.tool "${TASK_FILE}" >/dev/null \
  || fail "invalid JSON: ${TASK_FILE}"

container_state="$(docker inspect -f '{{.State.Running}}' "${OGGHUB_CONTAINER}" 2>/dev/null || true)"
[[ "${container_state}" == "true" ]] \
  || fail "${OGGHUB_CONTAINER} is not running"

trail_code="$(docker exec "${OGGHUB_CONTAINER}" \
  curl -sS -o /dev/null -w '%{http_code}' \
  -u "${OGG_ADMIN_USER}:${OGG_ADMIN_PASSWORD}" \
  "${API_ROOT}/trails/ca")"
[[ "${trail_code}" == "200" ]] \
  || fail "OGGHUB trail ca was not found; run this script after ADD EXTTRAIL ca"

task_code="$(docker exec "${OGGHUB_CONTAINER}" \
  curl -sS -o /dev/null -w '%{http_code}' \
  -u "${OGG_ADMIN_USER}:${OGG_ADMIN_PASSWORD}" \
  "${TASK_URL}")"

case "${task_code}" in
  200)
    printf '==> Update existing OGGHUB purge task: %s\n' "${TASK_NAME}"
    request PATCH "${TASK_URL}" "${TASK_FILE}" >/dev/null
    ;;
  404)
    printf '==> Create OGGHUB purge task: %s\n' "${TASK_NAME}"
    request POST "${TASK_URL}" "${TASK_FILE}" >/dev/null
    ;;
  *)
    fail "unexpected task lookup HTTP status: ${task_code}"
    ;;
esac

task_response="$(request GET "${TASK_URL}")"
printf '%s\n' "${task_response}" | python3 -c '
import json
import sys

document = json.load(sys.stdin)
task = document.get("response", document)
command = task.get("command", {})
schedule = task.get("schedule", {}).get("every", {})
keep = command.get("keep", [{}])[0]

expected = (
    task.get("enabled") is True
    and command.get("purgeType") == "trails"
    and command.get("useCheckpoints") is True
    and any(item.get("name") == "ca" for item in command.get("trails", []))
    and keep.get("type") == "min"
    and keep.get("units") == "files"
    and keep.get("value") == 10
    and schedule.get("units") == "minutes"
    and schedule.get("value") == 10
)
if not expected:
    raise SystemExit("ERROR: purge task verification failed")
' || fail "purge task verification failed"

printf 'OK: OGGHUB purge task %s is configured.\n' "${TASK_NAME}"
printf 'OK: ca keeps at least 10 trail files and is checked every 10 minutes.\n'
