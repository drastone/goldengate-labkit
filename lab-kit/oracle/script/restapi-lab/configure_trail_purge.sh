#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OGGHUB_CONTAINER="${OGGHUB_CONTAINER:-demo_ogg_23ai}"
OGGBD_CONTAINER="${OGGBD_CONTAINER:-demo_oggbd_23ai}"
OGG_ADMIN_USER="${OGG_ADMIN_USER:-oggadmin}"
OGG_ADMIN_PASSWORD="${OGG_ADMIN_PASSWORD:-WElcome1234##}"

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

request() {
  local container="$1"
  local method="$2"
  local url="$3"
  local data_file="${4:-}"

  if [[ -n "${data_file}" ]]; then
    docker exec -i "${container}" \
      curl -sS -u "${OGG_ADMIN_USER}:${OGG_ADMIN_PASSWORD}" \
      -H 'Content-Type: application/json' \
      -X "${method}" "${url}" -d @- <"${data_file}"
  else
    docker exec "${container}" \
      curl -sS -u "${OGG_ADMIN_USER}:${OGG_ADMIN_PASSWORD}" \
      -X "${method}" "${url}"
  fi
}

configure_task() {
  local label="$1"
  local container="$2"
  local deployment="$3"
  local trail="$4"
  local task_name="$5"
  local task_file="$6"
  local api_root="http://localhost/services/${deployment}/adminsrvr/v2"
  local task_url="${api_root}/tasks/${task_name}"
  local container_state trail_code task_code task_response

  [[ -r "${task_file}" ]] || fail "task definition was not found: ${task_file}"
  python3 -m json.tool "${task_file}" >/dev/null \
    || fail "invalid JSON: ${task_file}"

  container_state="$(docker inspect -f '{{.State.Running}}' "${container}" 2>/dev/null || true)"
  [[ "${container_state}" == "true" ]] || fail "${container} is not running"

  trail_code="$(docker exec "${container}" \
    curl -sS -o /dev/null -w '%{http_code}' \
    -u "${OGG_ADMIN_USER}:${OGG_ADMIN_PASSWORD}" \
    "${api_root}/trails/${trail}")"
  [[ "${trail_code}" == "200" ]] \
    || fail "${label} trail ${trail} was not found"

  task_code="$(docker exec "${container}" \
    curl -sS -o /dev/null -w '%{http_code}' \
    -u "${OGG_ADMIN_USER}:${OGG_ADMIN_PASSWORD}" \
    "${task_url}")"

  case "${task_code}" in
    200)
      printf '==> Update existing %s purge task: %s\n' "${label}" "${task_name}"
      request "${container}" PATCH "${task_url}" "${task_file}" >/dev/null
      ;;
    404)
      printf '==> Create %s purge task: %s\n' "${label}" "${task_name}"
      request "${container}" POST "${task_url}" "${task_file}" >/dev/null
      ;;
    *)
      fail "unexpected ${label} task lookup HTTP status: ${task_code}"
      ;;
  esac

  task_response="$(request "${container}" GET "${task_url}")"
  printf '%s\n' "${task_response}" | python3 -c '
import json
import sys

expected_trail = sys.argv[1]
document = json.load(sys.stdin)
task = document.get("response", document)
command = task.get("command", {})
schedule = task.get("schedule", {}).get("every", {})
keep = command.get("keep", [{}])[0]

expected = (
    task.get("enabled") is True
    and command.get("purgeType") == "trails"
    and command.get("useCheckpoints") is True
    and any(item.get("name") == expected_trail for item in command.get("trails", []))
    and keep.get("type") == "min"
    and keep.get("units") == "files"
    and keep.get("value") == 10
    and schedule.get("units") == "minutes"
    and schedule.get("value") == 10
)
if not expected:
    raise SystemExit("ERROR: purge task verification failed")
' "${trail}" || fail "${label} purge task verification failed"

  printf 'OK: %s purge task %s is configured.\n' "${label}" "${task_name}"
  printf 'OK: %s keeps at least 10 trail files and is checked every 10 minutes.\n' "${trail}"
}

command -v docker >/dev/null 2>&1 || fail "docker command was not found"
command -v python3 >/dev/null 2>&1 || fail "python3 command was not found"

configure_task OGGHUB "${OGGHUB_CONTAINER}" OGGHUB ca \
  PURGE_OGGHUB_TRAILS "${SCRIPT_DIR}/purge-ogghub-trails.json"
configure_task OGGBD "${OGGBD_CONTAINER}" OGGBD da \
  PURGE_OGGBD_TRAILS "${SCRIPT_DIR}/purge-oggbd-trails.json"
